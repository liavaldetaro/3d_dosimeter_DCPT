***************************
C# for dosimetry: General notes
***************************

Creating scripts that interact with the program Eclipse can lighten the burden when dealing with a large amount of data.

.. code-block:: php
   :linenos:

       $GLOBALS['TYPO3_CONF_VARS']['FE']['addRootLineFields'] .= ',tx_realurl_pathsegment';

       // Adjust to your needs
       $domain = 'www.example.com';
       $rootPageUid = 123;
       $rssFeedPageType = 9818; // pageType of your RSS feed page
