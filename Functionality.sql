use sport_clubs_service;
-- AUTHORIZATION ---------------------------------------------------------------------------------------------------------------------------------
drop procedure if exists auth_signal_access_denied;
delimiter $$
create procedure auth_signal_access_denied()
begin
	signal sqlstate '45000' set message_text = 'Access Denied';
end$$
delimiter ;

drop procedure if exists auth_fetch_application_id;
delimiter $$
create procedure auth_fetch_application_id(in service_code varchar(64), out application_id int)
begin
    select id from applications as a where a.service_code = service_code into application_id;
    if application_id is null then
		call auth_signal_access_denied();
	end if ;
end$$
delimiter ;

drop procedure if exists auth_fetch_access;
delimiter $$
create procedure auth_fetch_access(in service_code varchar(64), in uid varchar(48), out application_id int, out user_name varchar(50))
begin
    call auth_fetch_application_id(service_code, application_id);
    select name from users as u where u.application_id = application_id and u.uid = uid into user_name;
    if user_name is null then
		call auth_signal_access_denied();
	end if ;
end$$
delimiter ;

drop procedure if exists auth_check_admin;
delimiter $$
create procedure auth_check_admin(in application_id int, in user_uid varchar(48))
begin
    declare result int;
    select count(*) from admins as a where a.application_id = application_id and a.user_uid = user_uid into result;
    if result = 0 then
		call auth_signal_access_denied();
	end if ;
end$$
delimiter ;
-- ADMIN---------------------------------------------------------------------------------------------------------------------
drop procedure if exists admin_create_season;
delimiter $$
create procedure admin_create_season(in service_code varchar(64), in user_uid varchar(48), in name varchar(50), in start_date timestamp, in end_date timestamp)
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
	insert into seasons (application_id, name, start_date, end_date) values (application_id, name, start_date, end_date);
    select name, start_date, end_date;
end$$
delimiter ;

drop procedure if exists admin_create_competition;
delimiter $$
create procedure admin_create_competition(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in name varchar(50), in start_date timestamp, in end_date timestamp, in prize varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
	insert into competitions (application_id, season_name, name, admin_uid, start_date, end_date, prize) values (application_id, season_name, name, user_uid, start_date, end_date, prize);
    select season_name, name, user_uid, start_date, end_date, prize, null as winner_uid;
end$$
delimiter ;

-- USERS -----------------------------------------------------------------------------------------------------------------------
drop procedure if exists user_register;
delimiter $$
create procedure user_register(in service_code varchar(64), in user_uid varchar(48), in name varchar(50))
begin
    declare application_id int;
    call auth_fetch_application_id(service_code, application_id);
    insert into users (application_id, uid, name) values (application_id, user_uid, name);
end$$
delimiter ;

-- SEASONS-----------------------------------------------------------------------------------------------------------------------
drop procedure if exists season_get_all_seasons;
delimiter $$
create procedure season_get_all_seasons(in service_code varchar(64), in user_uid varchar(48))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    
	select name, start_date, end_date from seasons as s where s.application_id = application_id order by start_date desc;
end$$
delimiter ;

drop procedure if exists season_get_current_seasons;
delimiter $$
create procedure season_get_current_seasons(in service_code varchar(64), in user_uid varchar(48))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    
	select name, start_date, end_date from seasons as s where s.application_id = application_id and (current_timestamp() between start_date and end_date) order by start_date desc;
end$$
delimiter ;

-- USER SEASON SCORES -----------------------------------------------------------------------------------------------------------
drop procedure if exists season_get_high_scores;
delimiter $$
create procedure season_get_high_scores(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    
	select u.name, s.score from user_season_scores as s 
    inner join users as u on application_id = u.application_id and s.user_uid = u.uid
    where s.application_id = application_id and s.season_name = season_name order by score desc;
end$$
delimiter ;

-- COMPETITIONS ----------------------------------------------------------------------------------------------------------------
/*
drop procedure if exists competition_get_all_competitions;
delimiter $$
create procedure competition_get_all_competitions(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    
	select name, start_date, end_date from seasons as s where s.application_id = application_id order by start_date desc;
end$$
delimiter ;
*/