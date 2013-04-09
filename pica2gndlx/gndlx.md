# GND Light XML (GNDLX)

**GNDLX** ist eine vereinfachte XML-Repräsentation der Gemeinsamen Normdatei
(GND), die sich an der [GND-Ontologie] orientiert. Prinzipiell lassen sich alle
GND-Datensätze, abzüglich weniger benötigter Felder, in GNDLX ausdrücken.  Alle
GNDLX-Datensätze könne wiederum auch in der GND-Ontologie in RDF ausgedrückt
werden. Darüber hinaus ist ein Mapping in andere Formate wie MADS und SKOS
möglich. Ein Mapping von XML in JSON ist ebenfalls angedacht.

Die aktuelle Spezfikation von GNDLX liegt nur als Implementierung eines
Mappings von PICA (in der Variante des GBV) nach GNDLX vor (siehe
`pica2gndlx.xsl`). Das Unterverzeichnis `test` enthält mehrere
Beispieldatensätze (`*.ok.xml`).

## Übersicht

Alle GNDLX-Elemente können auf eine RDF-Klasse oder -Property der GND Ontologie
gemappt werden, z.B.  entspricht das XML-Element `<Person>` der Klasse
<http://d-nb.info/standards/elementset/gnd#Person>. Darüber hinaus sind weitere
Mappings möglich und im Folgenden angegeben.

## Entitätstypen

Folgende Entitätstypen werden in GNDLX unterschieden. 

* Work (= frbr:Work) 
* ConferenceOrEvent
* CorporateBody
* Family (= rdafrbr:Family)
* Person (= foaf:Person)
* Place or geographic name 
* Subject heading (= skos:Concept)

## Eigenschaften

### Allgemeine Eigenschaften (noch unvollständig)

Die mit einem "*" markierten Elemente können per XML-Attribut "uri" auf eine
andere Entität verweisen.

* biographicalOrHistoricalInformation (= skos:scopeNote)
* broaderTerm* (= skos:broaderTerm)
* dateOfBirth
* dateOfDeath
* definition (= skos:definition)
* gender
* placeOfBusiness*
* professionOrOccupation*

### Namen

variantName
preferredName

### Namensbestandteile (Unterelemente von Namen)

counting
epithetGenericNameTitleOrTerritory
forename
personalName
prefix
surname

### Zusätzliche Eigenschaften

Das zusätzliche XML-Attribut "ppn" kann auf die PPN des Normdatensatz in einem
PICA-Katalog verweisen.

## Referenzen

* [GND-Ontologie]
* [GBV Katalogisierungsrichtline zu Normdaten](http://www.gbv.de/bibliotheken/verbundbibliotheken/02Verbund/01Erschliessung/02Richtlinien/01KatRicht/inhalt.shtml#Normdaten)
* [Metadata Authority Description Schema (MADS)](http://www.loc.gov/standards/mads/) - a more complex XML format to express authority records
* ...

[GND-Ontologie]: http://d-nb.info/standards/elementset/gnd
