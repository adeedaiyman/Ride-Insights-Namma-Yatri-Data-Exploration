select * from trips;

select * from trip_details;

select * from loc;

select * from duration;

select * from payment;


--total trips

select count(*) as total_trips from trip_details;


--total drivers

select count(distinct(driverid)) as total_drivers from trips;


-- total earnings

select sum(fare) as total_earnings from trips;


-- total Completed trips

select count(end_ride) as total_trip_completed 
from trip_details
where end_ride = 1;

--total searches

select count(searches) as total_searches
from trip_details
where searches = 1;


--total searches which got estimate

select count(searches) as total_searches
from trip_details
where searches_got_estimate = 1;

--total searches for quotes

select count(searches_for_quotes) as total_searches_quotes
from trip_details
where searches_for_quotes = 1;

--total searches which got quotes

select count(searches_got_quotes) as total_searches_quotes
from trip_details
where searches_got_quotes = 1;

--total driver cancelled

select count(tripid) as total_driver_cancelled
from trip_details
where driver_not_cancelled = 0;


--total otp entered

select count(tripid) as total_otp_entered
from trip_details
where otp_entered = 1;


--total end ride

select count(tripid) as total_ride_ended
from trip_details
where end_ride = 1;

--cancelled bookings by driver

select count(tripid) as total_driver_cancelled
from trip_details
where driver_not_cancelled = 0;


--cancelled bookings by customer

select count(tripid) as trip_cancelled_by_customer
from trip_details
where customer_not_cancelled = 0;

--average distance per trip

select avg(distance) as avg_distance
from trips;


--average fare per trip

select avg(fare) as avg_fare from trips;

--distance travelled

select sum(distance) as distance_travelled
from trips;


-- which is the most used payment method 

select top 1 method, count(faremethod) as most_used_payment
from trips
join payment on trips.faremethod = payment.id
group by method
order by count(faremethod) desc;

-- the highest payment was made through which instrument
select * from trips;

select top 1 method, fare
from trips
join payment on trips.faremethod = payment.id
order by fare desc;

-- which two locations had the most trips

select top 2 assembly1 as location_, count(loc_to) as number_of_trips
from trips
join loc on loc.id = trips.loc_to
group by assembly1
order by number_of_trips desc;

--top 5 earning drivers

select top 5 driverid, sum(fare) as total_earnings
from trips 
group by driverid
order by total_earnings desc;


-- which duration had more trips

select * 
from (
select *,
rank() over(order by most_trips desc) as rnk 
from (
select duration, count(distinct tripid) as most_trips
from trips
group by duration) as max_trips) as trip
where rnk = 1;

-- which driver , customer pair had more orders

select * 
from (
select *,
rank() over(order by paired_trips desc) as rank_trips
from (
select driverid, custid, count(distinct tripid) as paired_trips
from trips
group by driverid, custid) as ranks) as pair_trips
where rank_trips = 1;

-- search to estimate rate

select sum(searches_got_estimate)*100.0/sum(searches) as ratio_to_searches_to_estimate
from trip_details;

-- estimate to search for quote rates
select sum(searches_for_quotes)*100.0/sum(searches_got_estimate) as ratio_to_searches_to_estimate
from trip_details;


-- which area got highest trips in which duration

select * from (
select *, rank() over(partition by duration order by total_trips desc) as rnk 
from (
select loc_to, assembly1 as area, duration, count(distinct tripid) as total_trips
from trips
join loc on loc.id = trips.loc_to
group by loc_to, assembly1, duration) as top_trips) as tripping
where rnk = 1;

-- which area got the highest fares, cancellations,trips,

select * from (
select *, rank() over(order by total_fare desc) as top_rank
from (
select loc_from, assembly1 as area, sum(fare) as total_fare
from trips
join loc on loc.id = trips.loc_to
group by loc_from, assembly1) as fare) as fares
where top_rank = 1;

select * from (
select *, rank() over(order by cancelled_trips desc) as rnk 
from (
select loc_from, assembly1 as area, count(driver_not_cancelled) as cancelled_trips
from trip_details
join loc on loc.id = trip_details.loc_from
where driver_not_cancelled = 0
group by loc_from, assembly1) as a) as b
where rnk = 1

select * from (
select *, rank() over(order by cancelled_trips desc) as rnk 
from (
select loc_from, assembly1 as area, count(customer_not_cancelled) as cancelled_trips
from trip_details
join loc on loc.id = trip_details.loc_from
where customer_not_cancelled = 0
group by loc_from, assembly1) as a) as b
where rnk = 1


select * from (
select *, rank() over(order by highest_trips desc) as rnk 
from (
select loc_from, assembly1 as area, count(distinct tripid) as highest_trips
from trip_details
join loc on loc.id = trip_details.loc_from
group by loc_from, assembly1) as a) as b
where rnk = 1


-- which duration got the highest trips and fares

select * from (
select *, rank() over(order by highest_duration_trips desc) as rnk
from 
(
select duration, count(distinct tripid) as highest_duration_trips
from trips
group by duration) as a) as b
where rnk = 1;

select * from (
select *, rank() over(order by highest_duration_fare desc) as rnk
from 
(
select duration, sum(fare) as highest_duration_fare
from trips
group by duration) as a) as b
where rnk = 1;