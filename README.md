# oauth2server

A ColdFusion component to manage generating access tokens, refresh token and authorization codes

[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/tested-with-testbox.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-coldfusion-9.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-coldfusion-10.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-45.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-5.svg)](https://cfmlbadges.monkehworks.com)

## Getting Started

Instantiate the component and pass in the required properties like so:

```
var secretKey = createUUID();
var clientId  = 'BF23473E-A6AA-477D-ADDEB3A6DC24D28E';
var issuer    = 'https://test.monkehserver.com/oauth/token';

var oOauth2Server = new oauth2server(
	secretKey = secretKey,
	issuer    = issuer,
	audience  = clientId
);
```

### Generating an Access Token

To generate an access token you need to pass in the `userId`, `clientId` and `issuer` values. The `scope` argument is optional and will default to an empty array if not provided.

```
var userId   = 1000;
var aScope = [
	'read-private',
	'write'
];

var stuAccessToken = oOAuth2Server.generateAccessToken(
	userId   = userId,
	clientId = clientId,
	issuer   = issuer,
	scope    = aScope
);
```

The response will contain your struct of information to send back to the calling application:

```
{
	"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MDgxNTgxMTIsImlzcyI6Imh0dHBzOi8vdGVzdC5tb25rZWhzZXJ2ZXIuY29tL29hdXRoL3Rva2VuIiwic3ViIjoxMDAwLCJleHAiOjE1MDgxNjE3MTIsInNjb3BlIjoicmVhZC1wcml2YXRlLHdyaXRlIiwiYXVkIjoiQkYyMzQ3M0UtQTZBQS00NzdELUFEREVCM0E2REMyNEQyOEUifQ.pLiNkS2GLW9Wp4tthm4MAyRUf0Y4LeYrKnkasXtCY24",
	"refresh_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MDgxNTgxMTIsImlzcyI6Imh0dHBzOi8vdGVzdC5tb25rZWhzZXJ2ZXIuY29tL29hdXRoL3Rva2VuIiwic3ViIjoxMDAwLCJzY29wZSI6InJlYWQtcHJpdmF0ZSx3cml0ZSIsImF1ZCI6IkJGMjM0NzNFLUE2QUEtNDc3RC1BRERFQjNBNkRDMjREMjhFIn0.ppGgMVTx-_s5GP6O5TTKwtVveyWJFRZZg9aEf9TMzUw",
	"token_type":"bearer",
	"expires_in":3600,
	"scope":"read-private,write"
}
```

A `refresh_token` value is provided with every response. Both the `access_token` and `refresh_token` values contained in the structure are self-signed JSON Web Tokens. This means that you do not have to store any of the tokens in your database (ideal for distributed systems).

### The Access Token

The contents of the `access_token` string, when decoded, will look similar to the following:

```
{
	"iat":1508158112,
	"iss":"https://test.monkehserver.com/oauth/token",
	"sub":1000,
	"exp":1508161712,
	"scope":"read-private,write",
	"aud":"BF23473E-A6AA-477D-ADDEB3A6DC24D28E"}
```

When your application received the `access_token` and decodes it, you can easily detect which user it is attributed to. Here's a breakdown of the properties:

* `iat`: issued at time (in seconds)
* `iss`: the issuer - this should match the endpoint that generated the token
* `sub`: the subscriber - the user id of the resource owner / user
* `exp`: the expiry time of the `access_token` (in seconds)
* `scope`: any scope values that may be in play
* `aud`: the audience that should be consuming this request (the client application)

### The Refresh Token

The contents of the `refresh_token` string, when decoded, will look similar to the following:

```
{
	"iat":1508158112,
	"iss":"https://test.monkehserver.com/oauth/token",
	"sub":1000,
	"scope":"read-private,write",
	"aud":"BF23473E-A6AA-477D-ADDEB3A6DC24D28E"
	}
```

You can see that the decoded token value closely resembles that of the `access_token` with one major difference as it does not include an expiry time.

Testing
----------------
The component has been tested on Adobe ColdFusion 9 and 10, Lucee 4.5 and Lucee 5.


Dependencies
----------------

This component has a dependency on the `cf-jwt` component, which handles the encoding and decoding of the JSON Web Tokens.

To install, simply run `box install` from within this project folder.


Download
----------------
[OAuth2 Server](https://github.com/coldfumonkeh/oauth2server/downloads)


### 1.0.0 - October 16, 2017

- Commit: Initial Release


MIT License

Copyright (c) 2012 Matt Gifford (Monkeh Works Ltd)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.