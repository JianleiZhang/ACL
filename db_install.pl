#!/usr/bin/perl

use strict;
use warnings;
use Mojo::Pg;
use utf8;

my $pg = Mojo::Pg->new('postgresql:///db');

my @table = (
  'DROP TABLE IF EXISTS users',
  'CREATE TABLE users (id SERIAL, username varchar, password varchar, roles integer ARRAY)',
  'DROP TABLE IF EXISTS permissions',
  'CREATE TABLE permissions (id SERIAL, name varchar, key varchar)',
  'DROP TABLE IF EXISTS roles',
  'CREATE TABLE roles (id SERIAL, name varchar, permissions integer ARRAY)',
);

my @data = (
  "INSERT INTO permissions VALUES (DEFAULT, 'permission_description_1', 'route_name_1')",
  "INSERT INTO permissions VALUES (DEFAULT, 'permission_description_2', 'route_name_2')",
  "INSERT INTO permissions VALUES (DEFAULT, 'permission_description_3', 'route_name_3')",
  "INSERT INTO roles VALUES (DEFAULT, 'admin', ARRAY[1,2,3])",
  "INSERT INTO roles VALUES (DEFAULT, 'user', ARRAY[1,2])",
  "INSERT INTO users VALUES (DEFAULT, 'user_1', '123456', ARRAY[1])",
  "INSERT INTO users VALUES (DEFAULT, 'user_2', '123456', ARRAY[2])",
);

foreach (@table){
  $pg->db->query($_);
}

foreach (@data){
  $pg->db->query($_);
}
