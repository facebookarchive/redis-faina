redis-faina
===========

A query analyzer that parses Redis' MONITOR command for counter/timing stats about query patterns

At its core, redis-faina uses the Redis MONITOR command, which echoes every single command (with arguments) sent to a Redis instance. It parses these
entries, and aggregates stats on the most commonly-hit keys, the queries that took up the most amount of time, and the most common key prefixes
as well.

Usage is simple:

    # reading from stdin
    redis-cli -p 6490 MONITOR | head -n <NUMBER OF LINES TO ANALYZE> | ./redis-faina.py [options]

    # reading a file
    redis-cli -p 6490 MONITOR | head -n <...> > /tmp/outfile.txt
    ./redis-faina.py [options] /tmp/outfile.txt
    
 		options:
  	--prefix-delimiter=...         	String to split on for delimiting prefix and rest of key, if not provided `:` is the default . --prefix-delimiter=#
  	--redis-version=...       			  Version of the redis server being monitored, if not provided `2.6` is the default. e.g. --redis-version=2.4


The output (anonymized below with 'zzz's) looks as follows:

<pre>
Overall Stats
========================================
Lines Processed     117773
Commands/Sec        11483.44

Top Prefixes
========================================
friendlist          69945
followedbycounter   25419
followingcounter    10139
recentcomments      3276
queued              7

Top Keys
========================================
friendlist:zzz:1:2     534
followingcount:zzz     227
friendlist:zxz:1:2     167
friendlist:xzz:1:2     165
friendlist:yzz:1:2     160
friendlist:gzz:1:2     160
friendlist:zdz:1:2     160
friendlist:zpz:1:2     156

Top Commands
========================================
SISMEMBER   59545
HGET        27681
HINCRBY     9413
SMEMBERS    9254
MULTI       3520
EXEC        3520
LPUSH       1620
EXPIRE      1598

Command Time (microsecs)
========================================
Median      78.25
75%         105.0
90%         187.25
99%         411.0

Heaviest Commands (microsecs)
========================================
SISMEMBER   5331651.0
HGET        2618868.0
HINCRBY     961192.5
SMEMBERS    856817.5
MULTI       311339.5
SADD        54900.75
SREM        40771.25
EXEC        28678.5

Slowest Calls
========================================
3490.75     "SMEMBERS" "friendlist:zzz:1:2"
2362.0      "SMEMBERS" "friendlist:xzz:1:3"
2061.0      "SMEMBERS" "friendlist:zpz:1:2"
1961.0      "SMEMBERS" "friendlist:yzz:1:2"
1947.5      "SMEMBERS" "friendlist:zpz:1:2"
1459.0      "SISMEMBER" "friendlist:hzz:1:2" "zzz"
1416.25     "SMEMBERS" "friendlist:zhz:1:2"
1389.75     "SISMEMBER" "friendlist:zzx:1:2" "zzz"
</pre>


One caveat on timing: MONITOR only shows the time a command completed, not when it started. On a very busy Redis server (like most of ours), this is
fine because there's always a request waiting to execute, but if you're at a lesser rate of requests, the time taken will not be accurate.

Have more stats / improvements you'd like to see to Redis-Faina? Please fork and send pull requests! And if analyzing hundreds of thousands of requests per second
across many systems is interesting to you, [drop us a note](http://instagram.com/about/jobs/) and tell us a bit about yourself--we're building out our dev & devops team
