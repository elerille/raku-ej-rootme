class Ej::RootMe
----------------

API to access to root-me.org

### multi method new

```raku
multi method new(
    Str:D :$api-key!
) returns Ej::RootMe
```

Create Ej::RootMe from an API key

### multi method new

```raku
multi method new(
    Str:D :$spip-session!
) returns Ej::RootMe
```

Create Ej::RootMe from the cookie C<spip_session>

### multi method new

```raku
multi method new(
    Str:D :$login!,
    Str:D :$password!
) returns Ej::RootMe
```

Create Ej::RootMe from login/password

### method challenges

```raku
method challenges(
    Str :$titre,
    Str :$soustitre,
    Str :$lang,
    Str :$score,
    Int:D :$skip where { ... } = 0
) returns Mu
```

Get a lazy seq of all Challenge

### method challenge

```raku
method challenge(
    Int:D $id_challenge
) returns Ej::RootMe::Challenge:D
```

Get the Challenge with id $id_challenge

### method auteurs

```raku
method auteurs(
    Str :$nom,
    Str :$status,
    Str :$lang,
    Int:D :$skip where { ... } = 0
) returns Mu
```

Get a lazy seq of all Auteur

### method auteur

```raku
method auteur(
    Int:D $id_auteur
) returns Ej::RootMe::Auteur:D
```

Get the Auteur with id $id_auteur

### method classement

```raku
method classement(
    Int:D :$skip where { ... } = 0
) returns Mu
```

Get a lazy seq of all Auteur ordered by position ASC

### method environnements-virtuels

```raku
method environnements-virtuels(
    Int:D :$skip where { ... } = 0
) returns Mu
```

Get a lazy seq of all EnvironnementVirtuel

### method environnement-virtuel

```raku
method environnement-virtuel(
    Int:D $id_environnement_virtuel
) returns Mu
```

Get the EnvironnementVirtuel with id $id_environnement_virtuel

class Ej::RootMe::EnvironnementVirtuel
--------------------------------------

Describe a virtual environment

### has Int:D(Any) $.id_environnement_virtuel

ID of virtual environment

### has Str:D $.nom

name

### has Str $.description_fr

french description

### has Str $.description_en

english description

### has Int(Any) $.time_to_root

???

### has Str $.os

OS of virtual environment

### method load

```raku
method load() returns Ej::RootMe::EnvironnementVirtuel
```

Load missing information

class Ej::RootMe::Auteur
------------------------

Describe an author

### has Int:D(Any) $.id_auteur

ID of author

### has Str $.nom

name

### has Str $.status

status

### has Int(Any) $.score

score

### has Int $.position

score

### has Positional @.challenges

list of challenge created by this author

### has Positional @.solutions

list of solutions wrote by this author

### has Positional @.validations

list of ??? by this author

### method load

```raku
method load() returns Ej::RootMe::Auteur
```

Load missing information

### has Int:D(Any) $.id_challenge

ID of challenge

### has Int(Any) $.id_rubrique

challenge is in the rubrique with thie ID

### has Mu $.lang

lang of challenge, it's only available if you load this object with C<$root-me.challenges();>

### has DateTime $.date_publication

date of publication

### has Str $.titre

title

### has Str $.soustitre

subtitle

### has Str $.rubrique

section

### has Int(Any) $.score

score

### has Str $.url_challenge

url for user to load challenge

### has Str $.difficulte

difficulty

### has Int $.validations

number of validation

### has Positional @.auteurs

list of author C<Array[Auteur]>

### method load

```raku
method load() returns Ej::RootMe::Challenge
```

Load missing information

