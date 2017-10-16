component extends='testbox.system.BaseSpec'{
	
	/*********************************** BDD SUITES ***********************************/
	
	function beforeAll(){

		secretKey = createUUID();
		clientId  = 'BF23473E-A6AA-477D-ADDEB3A6DC24D28E';
		issuer    = 'https://test.monkehserver.com/oauth/token';
		oOauth2Server = new oauth2server(
			secretKey = secretKey,
			issuer    = issuer,
			audience  = clientId
		);

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

				expect( sMemento ).toBeStruct().toHaveLength( 4 );

				expect( sMemento ).toHaveKey( 'secretKey' );
				expect( sMemento ).toHaveKey( 'issuer' );
				expect( sMemento ).toHaveKey( 'audience' );
				expect( sMemento ).toHaveKey( 'oJWT' );

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


			it( 'should generate an authorization code', function() {

				var userId   = 1000;
				var redirectURI = 'https://mycallback.fake';

				var authCode = oOAuth2Server.generateAuthCode(
					userId       = userId,
					clientId     = clientId,
					redirect_uri = redirectURI
				);

				expect( authCode ).toBeString();

				debug( authCode );

				// Decode the JWT to compare access token data
				var stuAuthCodeData = oOAuth2Server.decode( authCode );

				expect( stuAuthCodeData )
					.toBeStruct()
					.toHaveLength( 5 )
					.toHaveKey( 'iat' )
					.toHaveKey( 'sub' )
					.toHaveKey( 'exp' )
					.toHaveKey( 'redirect_uri' )
					.toHaveKey( 'aud' );


				expect( stuAuthCodeData[ 'sub' ] ).toBe( userId );
				expect( stuAuthCodeData[ 'redirect_uri' ] ).toBe( redirectURI );
				expect( stuAuthCodeData[ 'aud' ] ).toBe( clientId );

			} );


			it( 'should throw an error when an auth code token has expired', function() {

				expect( function(){ 
						oOAuth2Server.decode( expiredAuthCode );
					} ).toThrow( type="Invalid Token", regex = "Signature verification failed: Token expired" );


			} );

		});

	}
	
}
