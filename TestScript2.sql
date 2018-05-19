use sport_clubs_service;

call admin_create_season("123456", "uid 1", "season tes23t", '2002-12-20 01:02:03', '2003-12-20 01:02:03');

call admin_create_competition("123456", "uid 1", "season tes23t", "competitions test", '2002-12-20 01:02:03', '2003-12-20 01:02:03', "gift card");

--  (1, "season 1", '2003-12-20 01:02:03', '2003-12-31 01:02:03');
-- (in service_code varchar(64), in user_uid varchar(48), in season_name varchar(50), in name varchar(50), in start_date timestamp, in end_date timestamp, in prize varchar(50))