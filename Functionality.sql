use sport_clubs_service;
-- SERVICE --------------------------------------------------------------------------------------------------------------------------------------
drop procedure if exists service_create_application;
delimiter $$
create procedure service_create_application(in application_name varchar(50), in application_service_code varchar(64), in user_uid varchar(48), in user_name varchar(50), in admin_payment_information varchar(50))
begin
	declare application_id int;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
			ROLLBACK;
            select "An error ocurred. Changes have been rolled back" as error;
	END;
	START TRANSACTION;
		insert into applications (name, service_code) values (application_name, application_service_code);
        select last_insert_id() into application_id;
        insert into users (application_id, uid, name) values (application_id, user_uid, user_name);
        insert into admins (application_id, user_uid, payment_information) values (application_id, user_uid, admin_payment_information);
        update applications set owner_uid = user_uid where id = application_id;
	COMMIT;
end$$
delimiter ;
-- UTILITY --------------------------------------------------------------------------------------------------------------------------------------
drop procedure if exists util_fetch_paging;
delimiter $$
create procedure util_fetch_paging(in page int, in page_size int, out offset int)
begin
    select (page - 1) * page_size into offset;
end$$
delimiter ;

drop procedure if exists util_fetch_uid;
delimiter $$
create procedure util_fetch_uid(in application_id int, in user_name varchar(50), out user_uid varchar(48))
begin
    select uid from users as u where u.application_id = application_id and u.name = user_name into user_uid;
end$$
delimiter ;

drop function if exists util_fetch_payment_confirmed;
DELIMITER $$
create function util_fetch_payment_confirmed(application_id int, season_name varchar(50), competition_name varchar(50), user_uid varchar(48))
returns bool deterministic
begin
	declare result bool default null;
	select payment_confirmed from user_competition_scores as ucs 
    where ucs.application_id = application_id and ucs.season_name = season_name and ucs.competition_name = competition_name and ucs.user_uid = user_uid 
    into result;
	return result;
end $$
DELIMITER ;
/*
drop function if exists util_fetch_guess;
DELIMITER $$
create function util_fetch_guess(application_id int, season_name varchar(50), competition_name varchar(50), team_1_name varchar(50), team_2_name varchar(50), start_date timestamp, user_uid varchar(48))
returns bool deterministic
begin
	declare result int default null;
	select g.result from guesses as g 
    where g.application_id = application_id and g.season_name = season_name and g.competition_name = competition_name and g.team_1_name = team_1_name and g.team_2_name = team_2_name and g.start_date = start_date and g.user_uid = user_uid 
    into result;
	return result;
end $$
DELIMITER ;
*/
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

drop procedure if exists auth_check_owner;
delimiter $$
create procedure auth_check_owner(in application_id int, in user_uid varchar(48))
begin
    declare result int;
    select count(*) from applications where id = application_id and owner_uid = user_uid into result;
    if result = 0 then
		call auth_signal_access_denied();
	end if ;
end$$
delimiter ;
-- OWNER ---------------------------------------------------------------------------------------------------------------------
drop procedure if exists owner_check_owner;
delimiter $$
create procedure owner_check_owner(in service_code varchar(64), in user_uid varchar(48))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_owner(application_id, user_uid);
end$$
delimiter ;

drop procedure if exists owner_create_admin;
delimiter $$
create procedure owner_create_admin(in service_code varchar(64), in user_uid varchar(48), in admin_name varchar(48), in admin_payment_information varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    declare admin_uid varchar(48);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_owner(application_id, user_uid);
    call util_fetch_uid(application_id, admin_name, admin_uid);
    -- select uid from users as u where u.application_id = application_id and u.name = admin_name into admin_uid;
	insert into admins (application_id, user_uid, payment_information) values (application_id, admin_uid, admin_payment_information);
    select admin_name as name, admin_payment_information as payment_information;
end$$
delimiter ;
-- ADMIN---------------------------------------------------------------------------------------------------------------------
drop procedure if exists admin_check_admin;
delimiter $$
create procedure admin_check_admin(in service_code varchar(64), in user_uid varchar(48))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
end$$
delimiter ;

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
    select season_name, name, start_date, end_date, prize, null as winner, payment_information, null as payment_confirmed from admins as a 
    where a.application_id = application_id and a.user_uid = user_uid;
end$$
delimiter ;

drop procedure if exists admin_create_team;
delimiter $$
create procedure admin_create_team(in service_code varchar(64), in user_uid varchar(48), in name varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
	insert into teams (application_id, name) values (application_id, name);
    select name;
end$$
delimiter ;

drop procedure if exists admin_create_match;
delimiter $$
create procedure admin_create_match(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in team_1_name varchar(50), in team_2_name varchar(50), in start_date timestamp)
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
	insert into matches (application_id, season_name, competition_name, team_1_name, team_2_name, start_date) values (application_id, season_name, competition_name, team_1_name, team_2_name, start_date);
    select season_name, competition_name, team_1_name, team_2_name, start_date, null as result;
end$$
delimiter ;

drop procedure if exists admin_decide_match_result;
delimiter $$
create procedure admin_decide_match_result(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in team_1_name varchar(50), in team_2_name varchar(50), in start_date timestamp, in result int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare old_result int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
	
    select m.result from matches as m
    where m.application_id = application_id and m.season_name = season_name and m.competition_name = competition_name and m.team_1_name = team_1_name and m.team_2_name = team_2_name and m.start_date = start_date
    into old_result;
    
    if old_result is not null then
     call auth_signal_access_denied();
    end if ;
    
    update matches as m set m.result = result 
    where m.application_id = application_id and m.season_name = season_name and m.competition_name = competition_name and m.team_1_name = team_1_name and m.team_2_name = team_2_name and m.start_date = start_date;
    
    select season_name, competition_name, team_1_name, team_2_name, start_date, result;
end$$
delimiter ;

drop procedure if exists admin_get_pending_payments;
delimiter $$
create procedure admin_get_pending_payments(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
    
    select payment_code from user_competition_scores as ucs
    where ucs.application_id = application_id and ucs.season_name = season_name and ucs.competition_name = competition_name and ucs.payment_confirmed = false;
end$$
delimiter ;

drop procedure if exists admin_confirm_payment;
delimiter $$
create procedure admin_confirm_payment(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in payment_code varchar(8))
begin
	declare application_id int;
    declare user_name varchar(50);
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call auth_check_admin(application_id, user_uid);
    
    update user_competition_scores as ucs set ucs.payment_confirmed = true
    where ucs.application_id = application_id and ucs.season_name = season_name and ucs.competition_name = competition_name and ucs.payment_code = payment_code;
end$$
delimiter ;
-- USERS -----------------------------------------------------------------------------------------------------------------------
drop procedure if exists user_check_name_availability;
delimiter $$
create procedure user_check_name_availability(in service_code varchar(64), in user_name varchar(48))
begin
    declare application_id int;
    declare result int;
    call auth_fetch_application_id(service_code, application_id);
    select count(*) from users as u where u.application_id = application_id and u.name = user_name into result;
    if result > 0 then
		call auth_signal_access_denied();
	end if ;
		
end$$
delimiter ;

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
create procedure season_get_all_seasons(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select name, start_date, end_date from seasons as s where s.application_id = application_id order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists season_get_current_seasons;
delimiter $$
create procedure season_get_current_seasons(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select name, start_date, end_date from seasons as s 
    where s.application_id = application_id and (current_timestamp() between start_date and end_date) 
    order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists season_get_all_competitions;
delimiter $$
create procedure season_get_all_competitions(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select season_name, c.name, start_date, end_date, prize, u.name as winner, payment_information, (select util_fetch_payment_confirmed(application_id, season_name, c.name, user_uid)) as payment_confirmed from competitions as c 
    inner join admins as a on c.application_id = a.application_id and c.admin_uid = a.user_uid
    left join user_competition_scores as ucs on c.application_id = ucs.application_id and c.season_name = ucs.season_name and c.name = ucs.competition_name and c.winner_uid = ucs.user_uid
    left join users as u on c.application_id = u.application_id and u.uid = ucs.user_uid
	where c.application_id = application_id and c.season_name = season_name
    order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists season_get_current_competitions;
delimiter $$
create procedure season_get_current_competitions(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select season_name, c.name, start_date, end_date, prize, u.name as winner, payment_information, (select util_fetch_payment_confirmed(application_id, season_name, c.name, user_uid)) as payment_confirmed 
    from competitions as c 
    inner join admins as a on c.application_id = a.application_id and c.admin_uid = a.user_uid
    left join user_competition_scores as ucs on c.application_id = ucs.application_id and c.season_name = ucs.season_name and c.name = ucs.competition_name and c.winner_uid = ucs.user_uid
    left join users as u on c.application_id = u.application_id and u.uid = ucs.user_uid
	where c.application_id = application_id and c.season_name = season_name and (current_timestamp() between start_date and end_date)
    order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists season_get_high_scores;
delimiter $$
create procedure season_get_high_scores(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
    SET @position=page_offset;
    select @position:=@position+1 as position, h.user_name, h.score from
	(select u.name as user_name, s.score from user_season_scores as s 
    inner join users as u on application_id = u.application_id and s.user_uid = u.uid
    where s.application_id = application_id and s.season_name = season_name order by score desc limit page_size offset page_offset) as h;
end$$
delimiter ;
-- COMPETITIONS ----------------------------------------------------------------------------------------------------------------
drop procedure if exists competition_get_all_competitions;
delimiter $$
create procedure competition_get_all_competitions(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select c.season_name, c.name, start_date, end_date, prize, u.name as winner, payment_information, (select util_fetch_payment_confirmed(application_id, season_name, c.name, user_uid)) as payment_confirmed 
    from competitions as c 
    inner join admins as a on c.application_id = a.application_id and c.admin_uid = a.user_uid
    left join user_competition_scores as ucs on c.application_id = ucs.application_id and c.season_name = ucs.season_name and c.name = ucs.competition_name and c.winner_uid = ucs.user_uid
    left join users as u on c.application_id = u.application_id and u.uid = ucs.user_uid
	where c.application_id = application_id
    order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists competition_get_current_competitions;
delimiter $$
create procedure competition_get_current_competitions(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	select c.season_name, c.name, start_date, end_date, prize, u.name as winner, payment_information, (select util_fetch_payment_confirmed(application_id, c.season_name, c.name, user_uid)) as payment_confirmed 
    from competitions as c 
    inner join admins as a on c.application_id = a.application_id and c.admin_uid = a.user_uid
    left join user_competition_scores as ucs on c.application_id = ucs.application_id and c.season_name = ucs.season_name and c.name = ucs.competition_name and c.winner_uid = ucs.user_uid
    left join users as u on c.application_id = u.application_id and u.uid = ucs.user_uid
	where c.application_id = application_id and (current_timestamp() between start_date and end_date)
    order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists competition_get_high_scores;
delimiter $$
create procedure competition_get_high_scores(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
	SET @position=page_offset;
    select @position:=@position+1 as position, h.user_name, h.score from
	(select u.name as user_name, s.score from user_competition_scores as s 
    inner join users as u on application_id = u.application_id and s.user_uid = u.uid
    where s.application_id = application_id and s.season_name = season_name and s.competition_name = competition_name order by score desc limit page_size offset page_offset) as h;
end$$
delimiter ;

drop procedure if exists competition_get_all_matches;
delimiter $$
create procedure competition_get_all_matches(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
    select m.season_name, m.competition_name, m.team_1_name, m.team_2_name, m.start_date, m.result, g.result as guess 
    from matches as m
    left join guesses as g on g.application_id = m.application_id and g.season_name = m.season_name and g.competition_name = m.competition_name and g.team_1_name = m.team_1_name and g.team_2_name = m.team_2_name and g.start_date = m.start_date and g.user_uid = user_uid 
    where m.application_id = application_id and m.season_name = season_name and m.competition_name = competition_name order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists competition_get_upcoming_matches;
delimiter $$
create procedure competition_get_upcoming_matches(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
    select m.season_name, m.competition_name, m.team_1_name, m.team_2_name, m.start_date, m.result, g.result as guess
    from matches as m
    left join guesses as g on g.application_id = m.application_id and g.season_name = m.season_name and g.competition_name = m.competition_name and g.team_1_name = m.team_1_name and g.team_2_name = m.team_2_name and g.start_date = m.start_date and g.user_uid = user_uid 
    where m.application_id = application_id and m.season_name = season_name and m.competition_name = competition_name and m.start_date > current_timestamp() order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

-- MATCHES -----------------------------------------------------------------------------------------------------------------------------------------------------
drop procedure if exists match_get_all_matches;
delimiter $$
create procedure match_get_all_matches(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
    select m.season_name, m.competition_name, m.team_1_name, m.team_2_name, m.start_date, m.result, g.result as guess
    from matches as m
    left join guesses as g on g.application_id = m.application_id and g.season_name = m.season_name and g.competition_name = m.competition_name and g.team_1_name = m.team_1_name and g.team_2_name = m.team_2_name and g.start_date = m.start_date and g.user_uid = user_uid 
    where m.application_id = application_id order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists match_get_upcoming_matches;
delimiter $$
create procedure match_get_upcoming_matches(in service_code varchar(64), in user_uid varchar(48), in page int, in page_size int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare page_offset int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    call util_fetch_paging(page, page_size, page_offset);
    
    select m.season_name, m.competition_name, m.team_1_name, m.team_2_name, m.start_date, m.result, g.result as guess
    from matches as m
    left join guesses as g on g.application_id = m.application_id and g.season_name = m.season_name and g.competition_name = m.competition_name and g.team_1_name = m.team_1_name and g.team_2_name = m.team_2_name and g.start_date = m.start_date and g.user_uid = user_uid 
    where m.application_id = application_id and m.start_date > current_timestamp() order by start_date desc limit page_size offset page_offset;
end$$
delimiter ;

drop procedure if exists match_make_guess;
delimiter $$
create procedure match_make_guess(in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in competition_name varchar(50), in team_1_name varchar(50), in team_2_name varchar(50), in start_date timestamp, in result int)
begin
	declare application_id int;
    declare user_name varchar(50);
    declare count int;
    call auth_fetch_access(service_code, user_uid, application_id, user_name);
    
    select count(*) from guesses as g
    where g.application_id = application_id and g.season_name = season_name and g.competition_name = competition_name and g.team_1_name = team_1_name and g.team_2_name = team_2_name and g.start_date = start_date and g.user_uid = user_uid
    into count;
    
    if count > 0 then
		call auth_signal_access_denied();
	end if ;
    
    insert into guesses (application_id, season_name, competition_name, team_1_name, team_2_name, start_date, user_uid, result) values (application_id, season_name, competition_name, team_1_name, team_2_name, start_date, user_uid, result);
    
	select season_name, competition_name, team_1_name, team_2_name, start_date, null as result, result as guess; 
end$$
delimiter ;