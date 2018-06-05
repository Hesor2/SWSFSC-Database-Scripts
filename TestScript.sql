use sport_clubs_service;

call service_create_application("Sundby", "123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "Markus", "mobile pay");
call service_create_application("test application", "test code", "test owner uid", "test owner", "cash");

call user_register("123456", "27bcJRqsWWfldSkrhXW0d6IJ7xG2", "Nikolaj");
-- call owner_create_admin("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "Nikolaj", "stuff");

call user_check_name_availability("123456", "Nikola");

call admin_create_season("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test", '2001-12-20 01:02:03', '2003-12-20 01:02:03');
call admin_create_season("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test2", '2001-12-20 01:02:03', '2018-12-20 01:02:03');
call admin_create_season("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test3", '2001-12-20 01:02:03', '2019-12-20 01:02:03');
call admin_create_season("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test4", '2001-12-20 01:02:03', '2023-12-20 01:02:03');
call admin_create_season("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test5", '1994-12-20 01:02:03', '2017-12-20 01:02:03');

call admin_create_competition("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test", "competitions test", '2002-12-20 01:02:03', '2003-12-20 01:02:03', "gift card");

call season_get_all_seasons("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", 1, 10);
call season_get_current_seasons("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", 1, 10);

call season_get_high_scores("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test", 1, 10);

call season_get_all_competitions("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test", 1, 10);

call competition_get_current_competitions("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", 1, 10);

call competition_get_high_scores("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", 1, 10);

call admin_create_team("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "team 1");
call admin_create_team("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "team 2");
call admin_create_team("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "team 3");
call admin_create_team("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "team 4");

call admin_create_match("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "team 1", "team 2", '2001-12-20 01:02:03');
call admin_create_match("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "team 1", "team 3", '2001-12-20 01:02:03');
call admin_create_match("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "team 3", "team 4", '2019-12-20 01:02:03');

call competition_get_all_matches("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", 1, 10);
call competition_get_upcoming_matches("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", 1, 10);

call match_make_guess("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "team 3", "team 4", '2019-12-20 01:02:03', 2);

call match_get_all_matches("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", 1, 10);
call match_get_upcoming_matches("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", 1, 10);

call admin_decide_match_result("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "team 3", "team 4", '2019-12-20 01:02:03', 2);

call admin_get_pending_payments("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", 1, 10);

-- call admin_confirm_payment("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1", "season test","competitions test", "f1c3bfdd");



call admin_check_admin("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1");
call owner_check_owner("123456", "0h1HL0WQopYM1EduLKrYFW3bjJf1");