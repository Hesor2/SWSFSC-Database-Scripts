use sport_clubs_service;

drop role if exists 'service_interface';
create role 'service_interface';

grant execute on procedure auth_check_admin to 'service_interface';

grant execute on procedure admin_create_season to 'service_interface';
grant execute on procedure admin_create_competition to 'service_interface';
grant execute on procedure user_register to 'service_interface';
grant execute on procedure season_get_all_seasons to 'service_interface';
grant execute on procedure season_get_current_seasons to 'service_interface';
grant execute on procedure season_get_high_scores to 'service_interface';


drop user if exists 'service1'@'localhost';
create user 'service1'@'localhost' identified by 'password' default role 'service_interface' require ssl;

drop user if exists 'service2'@'localhost';
create user 'service2'@'localhost' identified by 'password' default role 'service_interface' require ssl;