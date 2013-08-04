etcd-ruby
====

API for the coreos/etcd daemon

Description
-----------

API for the coreos/etcd daemon

## Installation

As usual, you can install it using rubygems.

```
$ gem install etcd-ruby
```

## Usage

Set an etcd host for connections

```ruby
Etcd.host = "http://localhost:4001"
```

##### List machines/nodes

```ruby
resp = Etcd.machines
p resp.records
#
```

##### Set a key/value

```ruby
resp = Etcd.set "/foo/bar", "baz"
p resp.record
#
```

##### Set a key/value with TTL

```ruby
resp = Etcd.set "/foo/bar", "baz", ttl: 5
p resp.record
#
```

##### Test & Set a key/value

Raises an `Etcd::Error` if the key does not currently exist or the given `prev_value` is incorrect

```ruby
Etcd.set "key-does-not-exist", "baz", prev_value: "nope"
# raises Etcd::Error

Etcd.set "/foo/bar", "baz"

resp = Etcd.set "/foo/bar", "quux", prev_value: "this-value-is-wrong"
# raises Etcd::Error

resp = Etcd.set "/foo/bar", "quux", prev_value: "baz"
p resp.record
#
```

##### Get a value

```ruby
resp = Etcd.get "/foo/bar"
p resp.record
#
```

##### List keys

```ruby
Etcd.set "/foo/foo", "barbar"
Etcd.set "/foo/foo_dir/foo", "barbarbar"

resp = Etcd.list "/foo"
p resp.records
#
```

##### Delete key

```ruby
Etcd.delete "/foo"
```

##### Watch for a key/value change/insertion

Watch blocks on a key until it is edited via creation, deletion, or an update.
Passing an option `timeout: 5` will block for the given time in seconds. If no option is given then it will block forever.

Note, the timeout is only applied to the `read_timeout` and will stil raise an error if it cannot connect.

```ruby
resp = Etcd.watch "/foo/message", timeout: 5
p resp.data
```
