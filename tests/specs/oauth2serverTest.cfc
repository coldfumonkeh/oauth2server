component extends='testbox.system.BaseSpec'{

	/*********************************** BDD SUITES ***********************************/

	function beforeAll(){

		variables.secretKey = createUUID();
		variables.clientId  = 'BF23473E-A6AA-477D-ADDEB3A6DC24D28E';
		variables.issuer    = 'https://test.monkehserver.com/oauth/token';
		variables.hashSalt = 'mobile-radiation-otter';
		variables.stuInitParams = {
			'secretKey': variables.secretKey,
			'audience' : variables.clientId,
			'issuer'   : variables.issuer,
			'hashSalt' : variables.hashSalt
		};
		oOauth2Server = new oauth2server( argumentCollection = variables.stuInitParams );

		expiredAuthCode = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MDgxNTc2ODAsInN1YiI6MTAwMCwiZXhwIjoxNTA4MTU3NzEwLCJyZWRpcmVjdF91cmkiOiJodHRwczovL215Y2FsbGJhY2suZmFrZSIsImF1ZCI6IkJGMjM0NzNFLUE2QUEtNDc3RC1BRERFQjNBNkRDMjREMjhFIn0.ED1ISAraBllT23SbN9PIUI2CCS10gSpU89OhS1QgrNY';

	}

	function run(){

		describe( 'OAuth2 Server Component Suite', function(){

			it( 'should return the correct object', function(){

				expect( oOauth2Server ).toBeInstanceOf( 'oauth2server' );
				expect( oOauth2Server ).toBeTypeOf( 'component' );

			});

			it( 'should have the correct properties', function() {

				var sMemento = oOauth2Server.getMemento();

				expect( sMemento ).toBeStruct().toHaveLength( 6 );

				expect( sMemento ).toHaveKey( 'secretKey' );
				expect( sMemento ).toHaveKey( 'issuer' );
				expect( sMemento ).toHaveKey( 'audience' );
				expect( sMemento ).toHaveKey( 'oJWT' );
				expect( sMemento ).toHaveKey( 'oPKCE' );
				expect( sMemento ).toHaveKey( 'oHashID' );

			} );

			it( 'should have the correct methods', function() {

				expect( oOauth2Server ).toHaveKey( 'init' );
				expect( oOauth2Server ).toHaveKey( 'generateAccessToken' );
				expect( oOauth2Server ).toHaveKey( 'generateRefreshToken' );
				expect( oOauth2Server ).toHaveKey( 'generateAuthCode' );
				expect( oOauth2Server ).toHaveKey( 'decode' );
				expect( oOauth2Server ).toHaveKey( 'createEpoch' );
				expect( oOauth2Server ).toHaveKey( 'getMemento' );

			} );

			describe( 'Running Methods', function(){


				describe( 'The generateAccessToken() method', function(){


					it( 'should generate and return an access token', function(){

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

						expect( stuAccessToken )
							.toBeStruct()
							.toHaveLength( 5 )
							.toHaveKey( 'access_token' )
							.toHaveKey( 'expires_in' )
							.toHaveKey( 'refresh_token' )
							.toHaveKey( 'scope' )
							.toHaveKey( 'token_type' );

						expect( stuAccessToken[ 'expires_in' ] )
							.toBeNumeric()
							.toBe( '3600' );

						expect( stuAccessToken[ 'scope' ] )
							.toBeString()
							.toBe( arrayToList( aScope ) );

						expect( stuAccessToken[ 'token_type' ] )
							.toBeString()
							.toBe( 'bearer' );

						// Decode the JWT to compare access token data
						var stuAccessTokenData = oOAuth2Server.decode( stuAccessToken[ 'access_token' ] );

						expect( stuAccessTokenData )
							.toBeStruct()
							.toHaveLength( 6 )
							.toHaveKey( 'iat' )
							.toHaveKey( 'iss' )
							.toHaveKey( 'sub' )
							.toHaveKey( 'exp' )
							.toHaveKey( 'scope' )
							.toHaveKey( 'aud' );

						expect( stuAccessTokenData[ 'sub' ] )
							.toBeString()
							.toBe( userId );

						expect( stuAccessTokenData[ 'scope' ] )
							.toBeString()
							.toBe( arrayToList( aScope ) );

						// Decode the JWT to compare access token data
						var stuRefreshTokenData = oOAuth2Server.decode( stuAccessToken[ 'refresh_token' ] );

						expect( stuRefreshTokenData )
							.toBeStruct()
							.toHaveLength( 5 )
							.toHaveKey( 'iat' )
							.toHaveKey( 'iss' )
							.toHaveKey( 'sub' )
							.toHaveKey( 'scope' )
							.toHaveKey( 'aud' );

						expect( stuRefreshTokenData[ 'sub' ] )
							.toBeString()
							.toBe( userId );

					} );

				} );

				describe( 'The generateAuthCode() method', function(){

					describe( 'The hash option', function(){


						it( 'should generate an authorization code', function() {

							var userId   = 1000;
							var clientId = 2000;

							var authCode = oOAuth2Server.generateAuthCode(
								userId   = userId,
								clientId = clientId
							);

							expect( authCode ).toBeString().toHaveLength( 16 );

						} );

						it( 'should call the encodeHash method', function() {

							var userId   = 1000;
							var clientId = 2000;

							var mockService = createMock( 'oauth2server' ).init( argumentCollection = variables.stuInitParams );

							mockService.$( method = 'encodeHash', returns = '123' );

							var authCode = mockService.generateAuthCode(
								userId   = userId,
								clientId = clientId
							);

							expect( mockService.$count( 'encodeHash' ) ).toBe( 1 );

						} );

					} );

					describe( 'The JWT option', function(){

						it( 'should generate an authorization code as a JWT', function() {

							var userId   = 1000;
							var clientId = 2000;

							var authCode = oOAuth2Server.generateAuthCode(
								userId   = userId,
								clientId = clientId,
								format = 'jwt'
							);

							expect( authCode ).toBeString();
							expect( listLen( authCode, '.' ) ).toBe( 3 );

						} );

						it( 'should call the generateJWTAuthCode method', function() {

							var userId   = 1000;
							var clientId = 2000;

							var mockService = createMock( 'oauth2server' ).init( argumentCollection = variables.stuInitParams );

							mockService.$( method = 'generateJWTAuthCode', returns = '123' );

							var authCode = mockService.generateAuthCode(
								userId   = userId,
								clientId = clientId,
								format = 'jwt'
							);

							expect( mockService.$count( 'generateJWTAuthCode' ) ).toBe( 1 );

						} );

					} );

				} );

				describe( 'The encodeHash method', function(){

					it( 'should call the hashids.encode method', function(){

						var userId   = 1000;
						var clientId = 2000;

						var mockService = createMock( 'oauth2server' ).init( argumentCollection = variables.stuInitParams );
						var mockHashIds = createMock( 'utils.Hashids' ).init( 'salt', 8 );

						mockService.setoHashID( mockHashIds );

						mockHashIds.$( method = 'encode', returns = '123' );

						var resp = mockService.encodeHash( [] );

						expect( mockHashIds.$count( 'encode' ) ).toBe( 1 );

					} );

				} );

				describe( 'The decodeHash method', function(){

					it( 'should call the hashids.encode method', function(){

						var userId   = 1000;
						var clientId = 2000;

						var mockService = createMock( 'oauth2server' ).init( argumentCollection = variables.stuInitParams );
						var mockHashIds = createMock( 'utils.Hashids' ).init( 'salt', 8 );

						mockService.setoHashID( mockHashIds );

						mockHashIds.$( method = 'decode', returns = [] );

						var resp = mockService.decodeHash( 123 );

						expect( mockHashIds.$count( 'decode' ) ).toBe( 1 );

					} );

				} );

				describe( 'The decode() method', function(){

					it( 'should throw an error when an auth code token has expired', function() {

						expect( function(){
								oOAuth2Server.decode( expiredAuthCode );
							} ).toThrow( type="Invalid Token", regex = "Signature verification failed: Token expired" );

					} );

					it( 'should call the jwt component method', function(){

						var mockService = createMock( 'oauth2Server' ).init(
							secretKey = variables.secretKey,
							issuer    = variables.issuer,
							audience  = variables.clientId,
							hashSalt  = variables.hashSalt
						);
						var mockJWT = createMock( 'utils.deps.jwt.cf_jwt' ).init(
							secretKey = variables.secretKey,
							issuer    = variables.issuer,
							audience  = variables.clientId
						);
						mockService.setOJWT( mockJWT );
						mockJWT.$( method = 'decode', returns = {} );

						var resp = mockService.decode( '' );

						expect( mockJWT.$count( 'decode' ) ).toBe( 1 );

					} );

				} );


				describe( 'The validatePKCE() method', function(){

					it( 'should call the PKCE component method', function(){

						var mockService = createMock( 'oauth2Server' ).init(
							secretKey = variables.secretKey,
							issuer    = variables.issuer,
							audience  = variables.clientId,
							hashSalt  = variables.hashSalt
						);
						var mockPKCE = createMock( 'utils.deps.pkce.pkce' ).init();
						mockService.setOPKCE( mockPKCE );
						mockPKCE.$( method = 'verifyChallenge', returns = true );

						var resp = mockService.validatePKCE( 'verifier', 'challenge' );

						expect( mockPKCE.$count( 'verifyChallenge' ) ).toBe( 1 );

					} );

				} );

			} );

		});

	}

}
