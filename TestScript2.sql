use sport_clubs_service;
call service_create_application("test application", "test code", "test owner uid", "test owner", "cash");


call admin_create_season("123456", "uid 1", "season test", '2001-12-20 01:02:03', '2003-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test2", '2001-12-20 01:02:03', '2018-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test3", '2001-12-20 01:02:03', '2019-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test4", '2001-12-20 01:02:03', '2023-12-20 01:02:03');
call admin_create_season("123456", "uid 1", "season test5", '1994-12-20 01:02:03', '2017-12-20 01:02:03');

call admin_create_competition("123456", "uid 1", "season test", "competitions test", '2002-12-20 01:02:03', '2003-12-20 01:02:03', "gift card");

--  (1, "season 1", '2003-12-20 01:02:03', '2003-12-31 01:02:03');
-- (in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in name varchar(50), in start_date timestamp, in end_date timestamp, in prize varchar(50))

call season_get_all_seasons("123456", "uid 1", 1, 10);
call season_get_current_seasons("123456", "uid 1", 1, 10);

call season_get_high_scores("123456", "uid 1", "season test", 1, 10);

call season_get_all_competitions("123456", "uid 1", "season 1", 1, 10);

call competition_get_current_competitions("123456", "uid 1", 1, 10);