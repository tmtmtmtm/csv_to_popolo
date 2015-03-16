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

(none of these are required — it will simply extra data from any
suitably-named columns)

## Party/Faction Membership

Popolo allows for very complex modelling of roles and posts. Here,
however, we optimise for the most-common case: a legislator being
associated with a single political party/faction, possibly representing
a given region/constituency.

Basic Membership records will therefore be generated from the following
optional columns:

* `area`  (or `region` or `constituency`)
* `group` (or `party`, `bloc`, or `faction`)

An optional `group_id` can also be given, if you wish to use predefined
identifiers, otherwise a unique ID will be allocated.

An optional `start_date` and/or `end_date` can also given for the
membership.

## Executive Posts

If members of the legislature can also hold executive positions (e.g.
Prime Minister; Minister of Education; etc) these can be specified in an
`executive` column. 

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

