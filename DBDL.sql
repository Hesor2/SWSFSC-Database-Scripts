drop database if exists sport_clubs_service;
create database sport_clubs_service;

use sport_clubs_service;

create table if not exists applications
(
	id int auto_increment not null,
    name varchar(50) not null,
    service_code varchar(64) not null,
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

create table if not exists admins
(
	application_id int not null,
    user_uid varchar(48) not null,
    payment_information varchar(50) not null,
    primary key(application_id, user_uid),
    foreign key(application_id, user_uid) References users(application_id, uid)
);

create table if not exists seasons
(
    application_id int not null,
    name varchar(50) not null,
    start_date timestamp not null,
    end_date timestamp not null,
    primary key(application_id, name),
    foreign key(application_id) References applications(id)
);

create table if not exists user_season_scores
(
    application_id int not null,
    user_uid varchar(48) not null,
    season_name varchar(50) not null,
    score int not null,
    primary key(application_id, user_uid, season_name),
    foreign key(application_id, user_uid) References users(application_id, uid),
    foreign key(application_id, season_name) References seasons(application_id, name)
);

create table if not exists competitions
(
    application_id int not null,
    admin_uid varchar(48) not null,
    season_name varchar(50) not null,
    name varchar(50) not null,
    start_date timestamp not null,
    end_date timestamp not null,
    prize varchar(50) not null,
    winner_uid varchar(48),
    primary key(application_id, name),
    foreign key(application_id, admin_uid) References admins(application_id, user_uid),
    foreign key(application_id, season_name) References seasons(application_id, name),
    foreign key(application_id, winner_uid) References users(application_id, uid)
);

create table if not exists user_competition_scores
(
    application_id int not null,
    user_uid varchar(48) not null,
    competition_name varchar(50) not null,
    score int not null,
    primary key(application_id, user_uid, competition_name),
    foreign key(application_id, user_uid) References users(application_id, uid),
    foreign key(application_id, competition_name) References competitions(application_id, name)
);

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
    competition_name varchar(50) not null,
    team_1_name varchar(50) not null,
    team_2_name varchar(50) not null,
    start_date timestamp not null,
    result int,
    constraint result check (result between 0 and 2),
    constraint teams check (team_1_name not like team_2_name),
    primary key(application_id, competition_name, team_1_name, team_2_name, start_date),
    foreign key(application_id, competition_name) References competitions(application_id, name),
    foreign key(application_id, team_1_name) References teams(application_id, name),
    foreign key(application_id, team_2_name) References teams(application_id, name)
);

create table if not exists guesses
(
    application_id int not null,
    competition_name varchar(50) not null,
    team_1_name varchar(50) not null,
    team_2_name varchar(50) not null,
    start_date timestamp not null,
    user_uid varchar(48) not null,
    result int not null,
    constraint result check (result between 0 and 2),
    primary key(application_id, competition_name, team_1_name, team_2_name, start_date, user_uid),
    foreign key(application_id, competition_name, team_1_name, team_2_name, start_date) References matches(application_id, competition_name, team_1_name, team_2_name, start_date),
    foreign key(application_id, user_uid) References users(application_id, uid)
);