drop database if exists sport_clubs_service;
create database sport_clubs_service;

use sport_clubs_service;

create table if not exists applications
(
	id int auto_increment not null,
    name varchar(50) not null,
    service_code varchar(64) not null unique,
    owner_uid varchar(48),
    primary key(id)
);

create table if not exists users
(
	application_id int not null,
    uid varchar(48) not null,
    name varchar(50) not null,
    primary key(application_id, uid),
    foreign key(application_id) References applications(id)
);
ALTER TABLE users ADD UNIQUE unique_name(application_id, name);

create table if not exists admins
(
	application_id int not null,
    user_uid varchar(48) not null,
    payment_information varchar(50) not null,
    primary key(application_id, user_uid),
    foreign key(application_id, user_uid) References users(application_id, uid)
);
ALTER TABLE applications ADD CONSTRAINT fk_owner FOREIGN KEY (id, owner_uid) REFERENCES admins(application_id, user_uid);

create table if not exists seasons
(
    application_id int not null,
    name varchar(50) not null,
    start_date timestamp not null,
    end_date timestamp not null,
    primary key(application_id, name),
    foreign key(application_id) References applications(id)
);

drop trigger if exists seasons_insert_trigger;
DELIMITER //
Create Trigger seasons_insert_trigger before insert on seasons
For Each Row 
Begin
	if new.start_date > new.end_date then
		signal sqlstate '45000' set message_text = 'Start date cannot be after end date';
    end if ;
End//
DELIMITER ;

create table if not exists user_season_scores
(
    application_id int not null,
    season_name varchar(50) not null,
    user_uid varchar(48) not null,
    score int not null default 0,
    primary key(application_id, season_name, user_uid),
    foreign key(application_id, user_uid) References users(application_id, uid),
    foreign key(application_id, season_name) References seasons(application_id, name)
);
-- create index season_high_scores on user_season_scores(application_id, season_name, score);

create table if not exists competitions
(
    application_id int not null,
    season_name varchar(50) not null,
    name varchar(50) not null,
    admin_uid varchar(48) not null,
    start_date timestamp not null,
    end_date timestamp not null,
    prize varchar(50) not null,
    winner_uid varchar(48),
    primary key(application_id, season_name, name),
    foreign key(application_id, admin_uid) References admins(application_id, user_uid),
    foreign key(application_id, season_name) References seasons(application_id, name)
);

drop trigger if exists competitions_insert_trigger;
DELIMITER //
Create Trigger competitions_insert_trigger before insert on competitions
For Each Row 
Begin
	if new.start_date > new.end_date then
		signal sqlstate '45000' set message_text = 'Start date cannot be after end date';
    end if ;
End//
DELIMITER ;

create table if not exists user_competition_scores
(
    application_id int not null,
    season_name varchar(50) not null,
    competition_name varchar(50) not null,
    user_uid varchar(48) not null,
    score int not null default 0,
    payment_confirmed boolean not null default false,
    payment_code varchar(8) not null,
    primary key(application_id, season_name, competition_name, user_uid),
    foreign key(application_id, user_uid) References users(application_id, uid),
    foreign key(application_id, season_name, competition_name) References competitions(application_id, season_name, name)
);
ALTER TABLE competitions ADD CONSTRAINT fk_winner_uid FOREIGN KEY (application_id, season_name, name, winner_uid) REFERENCES user_competition_scores(application_id, season_name, competition_name, user_uid);
ALTER TABLE user_competition_scores ADD UNIQUE unique_payment_code (application_id, season_name, competition_name, payment_code);

create table if not exists teams
(
    application_id int not null,
    name varchar(50) not null,
    primary key(application_id, name),
    foreign key(application_id) References applications(id)
);

create table if not exists matches
(
    application_id int not null,
    season_name varchar(50) not null,
    competition_name varchar(50) not null,
    team_1_name varchar(50) not null,
    team_2_name varchar(50) not null,
    start_date timestamp not null,
    result int,
    primary key(application_id, season_name, competition_name, team_1_name, team_2_name, start_date),
    foreign key(application_id, season_name, competition_name) References competitions(application_id, season_name, name),
    foreign key(application_id, team_1_name) References teams(application_id, name),
    foreign key(application_id, team_2_name) References teams(application_id, name)
);

drop trigger if exists matches_insert_trigger;
DELIMITER //
Create Trigger matches_insert_trigger before insert on matches
For Each Row 
Begin
	if new.team_1_name like new.team_2_name then
		signal sqlstate '45000' set message_text = 'Team 1 and Team 2 cannot be the same';
    end if ;
    if new.result not between 0 and 2 then
		signal sqlstate '45000' set message_text = 'Result must be between 0 and 2';
    end if ;
End//
DELIMITER ;

drop trigger if exists matches_update_trigger;
DELIMITER //
Create Trigger matches_update_trigger before update on matches
For Each Row 
Begin
	if new.team_1_name = new.team_2_name then
		signal sqlstate '45000' set message_text = 'Team 1 and Team 2 cannot be the same';
    end if ;
    if new.result not between 0 and 2 then
		signal sqlstate '45000' set message_text = 'Result must be between 0 and 2';
    end if ;
End//
DELIMITER ;

drop trigger if exists matches_result_update_trigger;
DELIMITER //
Create Trigger matches_result_update_trigger after update on matches
For Each Row 
Begin
	declare done int default false;
    declare uid varchar(48);
    declare curs cursor for select user_uid from guesses where application_id = new.application_id and season_name = new.season_name and competition_name = new.competition_name 
		and team_1_name = new.team_1_name and team_2_name = new.team_2_name and start_date = new.start_date and result = new.result;
	declare continue handler for not found set done = true;
    open curs;
		read_loop: loop
			fetch curs into uid;
            if done then
				leave read_loop;
			end if ;
			update user_season_scores set score = score+1 where application_id = new.application_id and season_name = new.season_name and user_uid = uid;
			update user_competition_scores set score = score+1 where application_id = new.application_id and season_name = new.season_name and competition_name = new.competition_name and user_uid = uid;
		end loop;
	  close curs;
End//
DELIMITER ;

create table if not exists guesses
(
    application_id int not null,
    season_name varchar(50) not null,
    competition_name varchar(50) not null,
    team_1_name varchar(50) not null,
    team_2_name varchar(50) not null,
    start_date timestamp not null,
    user_uid varchar(48) not null,
    result int not null,
    primary key(application_id, season_name, competition_name, team_1_name, team_2_name, start_date, user_uid),
    foreign key(application_id, season_name, competition_name, team_1_name, team_2_name, start_date) References matches(application_id, season_name, competition_name, team_1_name, team_2_name, start_date),
    foreign key(application_id, user_uid) References users(application_id, uid)
);

drop trigger if exists guess_constraint_trigger;
DELIMITER //
Create Trigger guess_constraint_trigger before insert on guesses
For Each Row 
Begin
    if new.result not between 0 and 2 then
		signal sqlstate '45000' set message_text = 'Result must be between 0 and 2';
    end if ;
	if new.start_date > current_timestamp() then
		signal sqlstate '45000' set message_text = 'You cannot guess on an ongoing or previous match';
	end if;
End//
DELIMITER ;

drop trigger if exists guess_insert_trigger;
DELIMITER //
Create Trigger guess_insert_trigger after insert on guesses
For Each Row 
Begin
	declare season_entries int;
    declare competition_entries int;
    declare payment_code varchar(8);
    
    select count(*) from user_season_scores where application_id = new.application_id and user_uid = new.user_uid and season_name = new.season_name into season_entries;
    if season_entries = 0 then insert into user_season_scores (application_id, user_uid, season_name) values (new.application_id, new.user_uid, new.season_name);
    end if ;
    select count(*) from user_competition_scores where application_id = new.application_id and user_uid = new.user_uid and season_name = new.season_name and competition_name = new.competition_name into competition_entries;
    if competition_entries = 0 then 
		SELECT LEFT(UUID(), 8) INTO payment_code;
		insert into user_competition_scores (application_id, season_name, competition_name, user_uid, payment_code) values (new.application_id, new.season_name, new.competition_name, new.user_uid, payment_code);
    end if ;
End//
DELIMITER ;