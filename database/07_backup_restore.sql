-- BACKUP COMPLETO
-- mysqldump -u root -p tecnomarket_db > backup_tecnomarket_$(date +%Y%m%d).sql

-- BACKUP SOLO SCHEMA (sin datos)
-- mysqldump -u root -p -d tecnomarket_db > schema_tecnomarket.sql

-- BACKUP SOLO DATOS
-- mysqldump -u root -p -t tecnomarket_db > data_tecnomarket.sql

-- RESTAURACIÓN
-- mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS tecnomarket_db;"
-- mysql -u root -p tecnomarket_db < backup_tecnomarket.sql
