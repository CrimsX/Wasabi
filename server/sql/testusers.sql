insert into client values('user1', 'user', '1', '1234');
insert into client values('user2', 'user', '2', '1234');
insert into client values('user3', 'user', '3', '1234');

insert into friends values('user1', 'user2');
insert into friends values('user2', 'user1');
insert into friends values('user1', 'user3');
insert into friends values('user3', 'user1');

insert into servertable (ServerName, CreationDate, Owner) values ('test group 1', '1707169256897', 'user1');

insert into partof values ('user1', 1);
insert into partof values ('user2', 1);
insert into partof values ('user3', 1);
