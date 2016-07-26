# Popolo::CSV

Generate Popolo-format JSON from CSV

This is a (deliberately very simple) module/script for generating 
[Popolo-format JSON](http://www.popoloproject.com/) from CSV.

It does not try to cover every possible scenario — the expected use-case
is to quickly convert a simple table of data about legislators (e.g.
their name, email, party, and consituency), and then fill in the more
complex data by hand, or using a web-based system such as
[PopIt](https://popit.mysociety.org/).

It currently handles data from the following columns:
* `id`
* `name`
* `family_name`
* `given_name`
* `additional_name`
* `other_name`
* `honorific_prefix`
* `honorific_suffix`
* `patronymic_name`
* `sort_name`
* `email`
* `phone`
* `fax`
* `cell`
* `twitter`
* `gender`
* `birth_date`
* `death_date`
* `image`
* `summary`
* `biography`
* `national_identity`

(none of these are required — it will simply extract data from any
suitably-named columns)

If an email address is prefixed with `mailto:` (example: `mailto:username@example.com`), the script will remove this prefix (example result: `username@example.com`).

## Party/Faction Membership

Popolo allows for very complex modelling of roles and posts. Here,
however, we optimise for the most-common case: a legislator being
associated with a single political party/faction, possibly representing
a given region/constituency.

Basic Membership records will therefore be generated from the following
optional columns:

* `area`  (or `region` or `constituency`)
* `group` (or `party`, `bloc`, or `faction`)

An optional `start_date` and/or `end_date` can also given for the
membership.

## ID-generation

It is strongly recommended that `id` and `group_id` columns be provided.
If not, these will be generated from the `name` (or `group`) column. If
multiple people have the same name, this will do the wrong thing.

## Executive Posts

If members of the legislature can also hold executive positions (e.g.
Prime Minister; Minister of Education; etc) these can be specified in an
`executive` column. 

## Terms

Data for multiple Terms (Legislative Periods) can be added by
specifiying a `term` column. If you use this, you **must** also provide
an `id` column, otherwise we will create a new Person each time (which
almost certainly isn't what you want). We don't currently do anything
smart here to combine fields: at the minute we just take the Person data
from the first line that provides that, and combine the Membership data
from later versions. If this doesn't do what you expect, let me know:
it's all a little experimental at the moment.

## Other Links

Any of the following columns will be turned into suitable "External
Links" data:

* `website`
* `blog`
* `facebook`
* `flickr`
* `instagram`
* `wikipedia`
* `youtube`

