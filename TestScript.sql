use sport_clubs_service;

insert into applications (name, service_code) values ("Sundby", "123456");

insert into users (application_id, uid, name) values (1, "uid 1", "Markus");
insert into users (application_id, uid, name) values (1, "uid 2", "Nikolaj");
insert into admins (application_id, user_uid, payment_information) values (1, "uid 1", "mobile pay");

insert into seasons (application_id, name, start_date, end_date) values (1, "season 1", '2003-12-20 01:02:03', '2003-12-31 01:02:03');

insert into competitions(application_id, season_name, name, admin_uid, start_date, end_date, prize) values (1, "season 1", "competition 1", "uid 1", '2003-12-20 01:02:03', '2003-12-31 01:02:03', "gift-card");

insert into teams (application_id, name) values (1, "sundby team 1");
insert into teams (application_id, name) values (1, "sundby team 2");

insert into matches(application_id, season_name, competition_name, team_1_name, team_2_name, start_date) values (1, "season 1", "competition 1", "sundby team 1", "sundby team 2", '2002-12-20 01:02:03');

insert into guesses (application_id, season_name, competition_name, team_1_name, team_2_name, start_date, user_uid, result) values (1, "season 1", "competition 1", "sundby team 1", "sundby team 2", '2002-12-20 01:02:03', "uid 1", 2);

update matches set result = 2 where application_id = 1 and season_name = "season 1" and competition_name = "competition 1" and team_1_name = "sundby team 1" and team_2_name =  "sundby team 2" and start_date ='2002-12-20 01:02:03';