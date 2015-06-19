hQuery Patient API
=========

The patient API is a CoffeeScript API for accessing patient information. It defines the model available to queries executing in an [hQuery Gateway](http://github.com/hquery/query-gateway). 

This codebase is used to generate a patient.js file that used within the hQuery Gateway to support execution of queries. 

Dependencies
------------
minitest < 5.0.0

Install Instructions
--------------------

There is no need to install the patientapi directly, it will be pulled into the [hQuery Gateway](http://github.com/hquery/query-gateway) by Bundler during an install.

See the [hQuery Composer](http://github.com/hquery/query-composer) for installation instructions for both the hQuery Composer and Gateway
  
Usage Instructions
--------------------
To generate the patient.js locally run the following in the project root: 

`rake doc:generate_js`  

This generates a new directory `tmp/` and puts `patient.js` in it.  

NOTE: the `doc:` is required to indicate the namespace, without this the command will fail.

License
-------

Copyright 2011 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Project Practices
-----------------

Please try to follow our [Coding Style Guides](http://github.com/eedrummer/styleguide). Additionally, we will be using git in a pattern similar to [Vincent Driessen's workflow](http://nvie.com/posts/a-successful-git-branching-model/). While feature branches are encouraged, they are not required to work on the project.
