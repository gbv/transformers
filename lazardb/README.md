Zum Testen von per OAI-PMH auslieferbaren Datenformaten können in easyDB 5 XSLT-Skripte konfiguriert werden. Grundlage ist das easyDB-XML-Format, das mit XSLT 2.0 konvertiert werden kann.

XSLT-Skripte für einzelne Formate befinden sich in Verzeichnissen lazardb2FORMAT mit dem Dateinamen lazardb2FORMAT.xsl wobei FORMAT der Name des Formats ist.

Aus den einzelnen Format-Verzeichnissen können zum Testen per OAI-Datensätze abgerufen werden:

    ../lazardb/getrecord oai:lazar.gbv.de:4c5b995c-32b5-45c0-8ad4-8f5c3964bcdb

Abruf des easyDB-XML-Datensatz per OAI-PMH und lokale Konvertierung:

    ../lazardb/makerecord oai:lazar.gbv.de:4c5b995c-32b5-45c0-8ad4-8f5c3964bcdb

