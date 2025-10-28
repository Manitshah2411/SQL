-- sudo nano here/comes/the/path/of/the/config/file
SHOW config_file; -- to know the path of the config file.
-- Then find 'shared_preloaded_libraries = '' '
-- eg. shared_preload_libraries = 'pg_stat_statements, auto_explain'
-- Which will be commented by default, add the extention between the apostrophes and than save and restart the
-- server. (NOTE: This process is only for server based extention not for every single extention)
CREATE EXTENSION pg_stat_statements;


-- The hstore type allows you to store key-value pairs within a single column, similar to a 
-- Python dictionary or a JSON object.

CREATE EXTENSION IF NOT EXISTS hstore

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    attributes HSTORE
);

-- Insert some data
INSERT INTO products (name, attributes) VALUES
('Laptop', 'brand => "Apple", model => "MacBook Pro", year => "2024", color => "Space Gray"'),
('Keyboard', 'brand => "Logitech", layout => "US", wireless => "true", color => "Black"'),
('Monitor', 'brand => "Dell", size => "27 inch", resolution => "4K"'),
('Mouse', 'brand => "Logitech", wireless => "true", dpi => "1600"'),
('Webcam', 'brand => "Logitech", resolution => "1080p", focus => "auto"');

SELECT name, attributes -> 'model' AS brand FROM products;