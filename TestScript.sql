use sport_clubs_service;

call service_create_application("Sundby", "123456", "uid 1", "Markus", "mobile pay");
call service_create_application("test application", "test code", "test owner uid", "test owner", "cash");

call user_register("123456", "uid 2", "Nikolaj");
-- call owner_create_admin("123456", "uid 1", "Nikolaj", "stuff");

call user_check_name_availability("123456", "Nikola");

call admin_create_season("123456", "uid 1", "season test", '2001-12-20 01:02:03', '2003-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test2", '2001-12-20 01:02:03', '2018-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test3", '2001-12-20 01:02:03', '2019-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test4", '2001-12-20 01:02:03', '2023-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test5", '1994-12-20 01:02:03', '2017-12-20 01:02:03');

call admin_create_competition("123456", "uid 1", "season test", "competitions test", '2002-12-20 01:02:03', '2003-12-20 01:02:03', "gift card");

call season_get_all_seasons("123456", "uid 1", 1, 10);
call season_get_current_seasons("123456", "uid 1", 1, 10);

call season_get_high_scores("123456", "uid 1", "season test", 1, 10);

call season_get_all_competitions("123456", "uid 1", "season test", 1, 10);

call competition_get_current_competitions("123456", "uid 1", 1, 10);

call competition_get_high_scores("123456", "uid 1", "season test","competitions test", 1, 10);

insert into user_season_scores(application_id, season_name, user_uid, score) values (1, "season test", "uid 1", 400);
insert into user_season_scores(application_id, season_name, user_uid, score) values (1, "season test", "uid 2", 200);

insert into user_competition_scores(application_id, season_name, competition_name, user_uid, score, payment_code) values (1, "season test", "competitions test", "uid 1", 200, "yup");
insert into user_competition_scores(application_id, season_name, competition_name, user_uid, score, payment_code) values (1, "season test", "competitions test", "uid 2", 400, "yup2");