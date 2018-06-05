use sport_clubs_service;

drop role if exists 'service_interface';
create role 'service_interface';

grant execute on procedure owner_check_owner to 'service_interface';
grant execute on procedure owner_create_admin to 'service_interface';

grant execute on procedure admin_check_admin to 'service_interface';
grant execute on procedure admin_create_season to 'service_interface';
grant execute on procedure admin_create_competition to 'service_interface';
grant execute on procedure admin_create_team to 'service_interface';
grant execute on procedure admin_create_match to 'service_interface';
grant execute on procedure admin_decide_match_result to 'service_interface';
grant execute on procedure admin_get_pending_payments to 'service_interface';
grant execute on procedure admin_confirm_payment to 'service_interface';

grant execute on procedure user_check_name_availability to 'service_interface';
grant execute on procedure user_register to 'service_interface';

grant execute on procedure season_get_all_seasons to 'service_interface';
grant execute on procedure season_get_current_seasons to 'service_interface';
grant execute on procedure season_get_all_competitions to 'service_interface';
grant execute on procedure season_get_current_competitions to 'service_interface';
grant execute on procedure season_get_high_scores to 'service_interface';

grant execute on procedure competition_get_all_competitions to 'service_interface';
grant execute on procedure competition_get_current_competitions to 'service_interface';
grant execute on procedure competition_get_all_matches to 'service_interface';
grant execute on procedure competition_get_upcoming_matches to 'service_interface';
grant execute on procedure competition_get_high_scores to 'service_interface';

grant execute on procedure match_get_all_matches to 'service_interface';
grant execute on procedure match_get_upcoming_matches to 'service_interface';
grant execute on procedure match_make_guess to 'service_interface';


drop user if exists 'service1'@'localhost';
create user 'service1'@'localhost' identified by 'password' default role 'service_interface' require ssl;

drop user if exists 'service2'@'localhost';
create user 'service2'@'localhost' identified by 'password' default role 'service_interface';