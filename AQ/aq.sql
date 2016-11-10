-- zjištìní queue table pro danou queue

select queue_table from DBA_QUEUES
  where name like 'SA_OUTBOX';

-- ke queue table je nutno pøidat prefix 'AQ$'
select MSG_STATE, QUEUE, CONSUMER_NAME, count(*) from SYMADM.AQ$SA_JMS_Q
group by MSG_STATE, QUEUE, CONSUMER_NAME;




-- stav schedules

select schema, qname, destination, schedule_disabled, failures, last_error_msg 
  from DBA_QUEUE_SCHEDULES;