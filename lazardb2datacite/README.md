This directory contains XSLT scripts to convert easydDB5-XML format as configured in LaZAR to [DataCite XML].

The scripts should be tested after each update because changes in easyDB5-XML may break export!

Run test cases with: `../testrunner`

* **oairecord2easydb.xsl** extracts one easyDB XML record (XML element `objects`) from the response to a OAI-PMH getRecord request (root element `OAI-PMH`)

* **lazardb2datacite.xsl** transforms an easyDB `objects` element to a DataCite `resource` element
 

[DataCite XML]: https://schema.datacite.org/
