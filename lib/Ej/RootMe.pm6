# Copyright 2021 Élerille
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

#| API to access to root-me.org
unit class Ej::RootMe;

use Cro::HTTP::Client;
use URL;

has Cro::HTTP::Client:D $!client is built is required;


class Challenge {
    ...
}
class Auteur {
    ...
}
class EnvironnementVirtuel {
    ...
}


multi method raku(::?CLASS:D:) {
    ::?CLASS.^name ~ '.new';
}

#| Create Ej::RootMe from an API key
multi method new(::?CLASS:U:
                 Str:D :$api-key!,
        --> ::?CLASS:D
                 )
{
    my Cro::HTTP::Client::CookieJar:D $cookie-jar .= new;
    $cookie-jar.add-cookie:
            Cro::HTTP::Cookie.new: :name<api_key>, :value($api-key), :domain<api.www.root-me.org>, :path</>;
    self.bless: client => Cro::HTTP::Client.new(user-agent => "Ej::RootMe (0.0.1)",
                                                base-uri => "https://api.www.root-me.org/",
                                                :$cookie-jar),
}
#| Create Ej::RootMe from the cookie C<spip_session>
multi method new(::?CLASS:U:
                 Str:D :$spip-session!,
        --> ::?CLASS:D
                 )
{
    my Cro::HTTP::Client::CookieJar:D $cookie-jar .= new;
    $cookie-jar.add-cookie:
            Cro::HTTP::Cookie.new: :name<spip_session>, :value($spip-session), :domain<api.www.root-me.org>, :path</>;
    self.bless: client => Cro::HTTP::Client.new(user-agent => "Ej::RootMe (0.0.1)",
                                                base-uri => "https://api.www.root-me.org/",
                                                :$cookie-jar),
}
#| Create Ej::RootMe from login/password
multi method new(::?CLASS:U:
                 Str:D :$login!,
                 Str:D :$password!,
        --> ::?CLASS:D
                 )
{
    my $client = Cro::HTTP::Client.new(user-agent => "Ej::RootMe (0.0.1)",
                                       base-uri => "https://api.www.root-me.org/");
    my %info = $client.get("login", query => { :$login, :$password }).result.body.result[0]<info>;
    if %info<code> != 200 {
        die "Unable to login (" ~ %info<message> ~ ")";
    }
    self.new: spip-session => %info<spip_session>;
}

#| Get a lazy seq of all Challenge
method challenges(::?CLASS:D:
                  Str :$titre, #= filter on title
                  Str :$soustitre,  #= filter on subtitle
                  Str :$lang, #= filter on language
                  Str :$score, #= filter on score
                  UInt:D :$skip = 0, #= skip this first element
                  )
{
    my %query;
    %query<titre> = $titre         with $titre;
    %query<soustitre> = $soustitre with $soustitre;
    %query<lang> = $lang           with $lang;
    %query<score> = $score         with $score;
    self!pagination("challenges", :$skip, :%query)
    ==> map({ Challenge.new: |%$_, :api(self) })
    ==> return;
}

#| Get the Challenge with id $id_challenge
method challenge(::?CLASS:D:
                 Int:D $id_challenge,
        --> Challenge:D
                 )
{
    Challenge.new: |$!client.get("challenges/$id_challenge").result.body.result,
                   :api(self),
                   :$id_challenge,
                   ;
}

#| Get a lazy seq of all Auteur
method auteurs(::?CLASS:D:
               Str :$nom, #= filter on name
               Str :$status, #= filter on status
               Str :$lang, #= filter on language
               UInt:D :$skip = 0, #= skip this first element
               )
{
    my %query;
    %query<nom> = $nom       with $nom;
    %query<status> = $status with $status;
    %query<lang> = $lang     with $lang;
    self!pagination("auteurs", :$skip, :%query)
    ==> map({ Auteur.new: |%$_, :api(self) })
    ==> return;
}

#| Get the Auteur with id $id_auteur
method auteur(::?CLASS:D:
              Int:D $id_auteur,
        --> Auteur:D
              )
{
    Auteur.new: |$!client.get("auteurs/$id_auteur").result.body.result,
                :api(self),
                ;
}
#| Get a lazy seq of all Auteur ordered by position ASC
method classement(::?CLASS:D:
                  UInt:D :$skip = 0, #= skip this first element
                  )
{
    my %query;
    self!pagination("classement", :$skip, :%query)
    ==> map({ Auteur.new: position => $_<place>, |%$_, :api(self) })
    ==> return;
}

#| Get a lazy seq of all EnvironnementVirtuel
method environnements-virtuels(::?CLASS:D:
                               UInt:D :$skip = 0, #= skip this first element
                               )
{
    my %query;
    self!pagination("environnements_virtuels", :$skip, :%query)
    ==> map({ EnvironnementVirtuel.new: |%$_, :api(self) })
    ==> return;
}
#| Get the EnvironnementVirtuel with id $id_environnement_virtuel
method environnement-virtuel(::?CLASS:D:
                             Int:D $id_environnement_virtuel,
                             )
{
    EnvironnementVirtuel.new: |$!client.get("environnements_virtuels/$id_environnement_virtuel").result.body.result,
                              :api(self),
                              :$id_environnement_virtuel,
                              ;
}

method !pagination(::?CLASS:D:
                   Str:D $path,
                   Str:D $pagination_name = $path,
                   UInt:D :$skip = 0,
                   :%query
                   )
{
    my $debut_name = "debut_$pagination_name";

    %query{$debut_name} = $skip;

    lazy gather {
        loop {
            my ($data, @suppl) = $!client.get($path, :%query).result.body.result;
            my $min = $data.keys».Int.min;
            my $max = $data.keys».Int.max;
            for $min .. $max -> $k {
                take $data{$k};
            }
            if @suppl[0]<rel>:exists && @suppl[0]<rel> eq 'next' {
                %query{$debut_name} = URL.new(@suppl[0]<href>).query{$debut_name};
            } elsif @suppl[1]<rel> && @suppl[1]<rel> eq 'next' {
                %query{$debut_name} = URL.new(@suppl[1]<href>).query{$debut_name};
            } else {
                last;
            }
            say "Next page";
        }
    }
}



#| Describe a virtual environment
class EnvironnementVirtuel {
    has Ej::RootMe:D $!api is built is required;
    #| ID of virtual environment
    has Int:D() $.id_environnement_virtuel is required;

    #| name
    has Str:D $.nom is required;

    #| french description
    has Str $.description_fr;
    #| english description
    has Str $.description_en;
    #| ???
    has Int() $.time_to_root;
    #| OS of virtual environment
    has Str $.os;

    #| Load missing information
    method load(::?CLASS:D: --> ::?CLASS:D) {
        my ::?CLASS:D $other = $!api.auteur($!id_environnement_virtuel);
        $!description_fr = $other.description_fr;
        $!description_en = $other.description_en;
        $!time_to_root = $other.time_to_root;
        $!os = $other.os;
        self;
    }
}

#| Describe an author
class Auteur {
    has Ej::RootMe:D $!api is built is required;
    #| ID of author
    has Int:D() $.id_auteur is required;

    #| name
    has Str $.nom;

    #| status
    has Str $.status;
    #| score
    has Int() $.score;
    #| score
    has Int $.position;
    #| list of challenge created by this author
    has @.challenges;
    #| list of solutions wrote by this author
    has @.solutions;
    #| list of ??? by this author
    has @.validations;

    method new(::?CLASS:U:
               *%args
               )
    {
        with %args<challenges> {
            %args<challenges> = %args<challenges>.values.map({
                Challenge.new: |$_, api => %args<api>
            });
        }
        self.bless: |%args
    }

    #| Load missing information
    method load(::?CLASS:D: --> ::?CLASS:D) {
        my ::?CLASS:D $other = $!api.auteur($!id_auteur);
        $!nom = $other.nom;
        $!status = $other.status;
        $!score = $other.score;
        $!position = $other.position;
        @!challenges = $other.challenges;
        @!solutions = $other.solutions;
        @!validations = $other.validations;
        self;
    }
}

class Challenge {
    has Ej::RootMe:D $!api is built is required;
    #| ID of challenge
    has Int:D() $.id_challenge is required;

    #| challenge is in the rubrique with thie ID
    has Int() $.id_rubrique;
    #| lang of challenge, it's only available if you load this object with C<$root-me.challenges();>
    has $.lang;
    #| date of publication
    has DateTime $.date_publication;
    #| title
    has Str $.titre;

    #| subtitle
    has Str $.soustitre;
    #| section
    has Str $.rubrique;
    #| score
    has Int() $.score;
    #| url for user to load challenge
    has Str $.url_challenge;
    #| difficulty
    has Str $.difficulte;
    #| number of validation
    has Int $.validations;
    #| list of author C<Array[Auteur]>
    has @.auteurs;

    method new(::?CLASS:U:
               *%args
               )
    {
        with %args<date_publication> {
            %args<date_publication>.=subst(' ', 'T');
            %args<date_publication>.=DateTime;
        }
        with %args<auteurs> {
            %args<auteurs> = %args<auteurs>.values.map({
                Auteur.new: |$_, api => %args<api>
            });
        }
        self.bless: |%args
    }

    #| Load missing information
    method load(::?CLASS:D: --> ::?CLASS:D) {
        my ::?CLASS:D $other = $!api.challenge($!id_challenge);
        $!id_rubrique = $other.id_rubrique;
        $!date_publication = $other.date_publication;
        $!titre = $other.titre;
        $!soustitre = $other.soustitre;
        $!rubrique = $other.rubrique;
        $!score = $other.score;
        $!url_challenge = $other.url_challenge;
        $!difficulte = $other.difficulte;
        $!validations = $other.validations;
        @!auteurs = $other.auteurs;
        self;
    }

}
