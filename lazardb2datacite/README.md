This directory contains XSLT scripts to convert easydDB5-XML format as configured in LaZAR to [DataCite XML].

The scripts should be tested after each update because changes in easyDB5-XML may break export!

**oairecord2easydb.xsl** extracts one easyDB XML record (XML element `objects`) from the response to a OAI-PMH getRecord request (root element `OAI-PMH`). Download and extract a record:

~~~
curl 'https://lazardb.gbv.de/api/plugin/base/oai/oai?verb=GetRecord&identifier=oai%3Alazar.gbv.de%3Ab79de4e5-8d1f-4840-b85f-e052db92a52f&metadataPrefix=easydb' \
    | xsltproc oairecord2easydb.xsl - > 6303.in.xml
~~~

To update a record via OAI-PMH call `update-record` with a record id, e.g.:

~~~
$ ./update-record 6303
test/6303.in.xml - updated via OAI
~~~

**lazardb2datacite.xsl** transforms an easyDB `objects` element to a DataCite `resource` element
 
Run test cases with: `../testrunner`

[DataCite XML]: https://schema.datacite.org/
