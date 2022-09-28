# oauth2server

A ColdFusion component to manage generating access tokens, refresh token and authorization codes

[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/tested-with-testbox.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-coldfusion-9.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-coldfusion-10.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-45.svg)](https://cfmlbadges.monkehworks.com)
[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-5.svg)](https://cfmlbadges.monkehworks.com)


Dependencies
----------------

This component has a dependency on the `cf-jwt` component, which handles the encoding and decoding of the JSON Web Tokens.

It also has a dependency on the `pkce` component, which handles the generation and verification of PKCE (Proof Key for Code Exchange) values for the OAuth 2.0 authorization code flow.

To install, simply run `box install` from within this project folder.

The component also makes use of the hashids CFML component created by Dan G. Switzer, II: 
https://github.com/dswitzer/hashids.coldfusion




The OAuth2 Server component has been redevloped to allow you to choose to create your authorization codes as encrypted JWT strings or as hash id values.

By default, the length of the hashids is set to 16 characters. This can be adjusted in the constructor method.

The `hashSalt` parameter is used to salt the hashid values.

The `secretKey` parameter is used to encode the JWT data.


## Getting Started

Instantiate the component and pass in the required properties like so:

```
var secretKey = createUUID();
var clientId  = 'BF23473E-A6AA-477D-ADDEB3A6DC24D28E';
var issuer    = 'https://test.monkehserver.com/oauth/token';

var oOauth2Server = new oauth2server(
	secretKey      = secretKey,
	issuer         = issuer,
	audience       = clientId,
	hashSalt       = 'some-random-string',
	authCodeLength = 16 // default is 16
);
```

### Generating an authorization code

To generate an authorization code (the first step in the OAuth2 server-side flow) simply provide the `userId` from the resource owner (after they have logged into your application) and a numeric representation for the `clientId`:

```
var authCode = oOAuth2Server.generateAuthCode(
	userId   = userId,
	clientId = clientId,
	format   = 'hash' // default value is hash
);
```

This will generate a hashId value to the length declared in the component configuration, for example:

```gB0NV05ehAs8lkQy```

This can be decoded to read the numeric values sent in:

```
var arrData = oauth2server.decodeHash( 'gB0NV05ehAs8lkQy' );

// resulting in [ 100, 27658 ], for example
```

Alterantively, you can choose to create a JWT authentication code:

```
var authCode = oOAuth2Server.generateAuthCode(
	userId   = userId,
	clientId = clientId,
	format   = 'jwt'
);
```

This will generate a self-signed authorization code. As such, you do not need to store it in any database for persistence (ideal for distributed systems).

The returned auth code will resemble the following:

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2NjQzNzQyMzUsInN1YiI6MTAwMCwiZXhwIjoxNjY0Mzc0MjY1LCJhdWQiOjIwMDB9.JgwUNpEuq_DVYdqhm-0u9Vr7QA_lxMCl9_JhhUzG0WI
```

When it is sent back to your server to request the access token, you can decode it to obtain the necessary data:

```
var stuAuthCodeData = oOAuth2Server.decode( authCode );
```

In this example, `stuAuthCodeData` will contain the following information within the structure:

```
{
  "iat": 1664374235, // issued at
  "sub": 1000, // the user id (subscriber)
  "exp": 1664374265, // expiry time
  "aud": 2000 // the client id (audience)
}
```

* `iat`: issued at time (in seconds)
* `sub`: the subscriber - the userId / resource owner Id
* `exp`: the expiry time (in seconds)
* `aud`: the audience that should be consuming this request (the client application)

It is important to note that the authorization code is only valid for a maximum of 30 seconds to avoid any interference.

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
	"aud":"BF23473E-A6AA-477D-ADDEB3A6DC24D28E"
}
```

When your application received the `access_token` and decodes it, you can easily detect which user it is attributed to. Here's a breakdown of the properties:

* `iat`: issued at time (in seconds)
* `iss`: the issuer - this should match the endpoint that generated the token
* `sub`: the subscriber - the user id of the resource owner / user
* `exp`: the expiry time of the `access_token` (in seconds)
* `scope`: any scope values that may be in play
* `aud`: the audience that should be consuming this request (the client application)

It is worth noting that the `access_token` value is set to expire within 60 minutes of generation.

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


Download
----------------
[OAuth2 Server](https://github.com/coldfumonkeh/oauth2server/downloads)


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