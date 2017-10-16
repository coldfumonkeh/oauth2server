/**
* @displayname oauth2server
* @output false
* @hint The oauth2server object.
* @author Matt Gifford
* @website https://www.monkehworks.com
* @purpose A ColdFusion Component to manage creation of OAuth2 access and refresh tokens
**/
component accessors="true" {

	property name="secretKey" type="string";
	property name="issuer" type="string";
	property name="audience" type="string";
	property name="oJWT" type="component";

	/**
	* Constructor
	*/
	public function init(
		required string secretKey,
		required string issuer,
		required string audience
	){
		setSecretKey( arguments.secretKey );
		setIssuer( arguments.issuer );
		setAudience( arguments.audience );
		setoJWT( createObject( 'component', 'cf-jwt.cf_jwt' ).init(
			secretkey = getSecretKey(),
			issuer    = arguments.issuer,
			audience  = arguments.audience
		) );
		return this;
	}



	/**
	* Generate the access token and refresh values
	* @userId The user ID of the user this token is for
	* @clientId The client ID of the app that is generating this token
	* @issuer The issuer (the token endpoint)
	* @scope An array of scopes this token is valid for
	*/
	function generateAccessToken(
		required string userId,
		required string clientId,
		required string issuer,
		array scope = []
	){
		var stuResponse = {};
		var oJWT        = getOJWT();
		var dateIssued  = now();
		var dateExpires = dateAdd( 'n', 60, dateIssued );
		var stuPayload  = {
			'sub'  : arguments.userId, // Subject (The user ID)
			'iss'  : arguments.issuer, // Issuer (the token endpoint)
			'aud'  : arguments.clientId, // Audience (intended for use by the client that generated the token)
			'iat'  : createEpoch( dateIssued ), // Issued At
			'exp'  : createEpoch( dateExpires ), // Expires At
			'scope': arrayToList( arguments.scope )
		};
 
		stuResponse[ 'access_token' ]  = oJWT.encode( stuPayload );
		stuResponse[ 'token_type' ]    = 'bearer';
		stuResponse[ 'expires_in' ]    = 3600;
		stuResponse[ 'refresh_token' ] = generateRefreshToken( argumentCollection = arguments );
		stuResponse[ 'scope' ] = arrayToList( arguments.scope );

		return stuResponse;

	}


	/**
	* Generate a refresh token
	* @userId The user ID of the user this token is for
	* @clientId The client ID of the app that is generating this token
	* @issuer The issuer (the token endpoint)
	* @scope An array of scopes this token is valid for
	*/
	function generateRefreshToken(
		required string userId,
		required string clientId,
		required string issuer,
		array scope = []
	){
		var oJWT          = getOJWT();
		var dateIssued    = now();
		var dateExpires   = dateAdd( 'n', 60, dateIssued );
		var stuPayload    = {
			'sub'  : arguments.userId, // Subject (The user ID)
			'iss'  : arguments.issuer, // Issuer (the token endpoint)
			'aud'  : arguments.clientId, // Audience (intended for use by the client that generated the token)
			'iat'  : createEpoch( dateIssued ), // Issued At
			'scope': arrayToList( arguments.scope )
		};

		return oJWT.encode( stuPayload );
	}


	/**
	* Generate a self-encoded authorization code
	* @userId The user ID of the user this token is for
	* @clientId The client ID of the app that is generating this token
	* @redirect_uri The redirect URI to send the code back to
	*/
	function generateAuthCode(
		required string userId,
		required string clientId,
		required string redirect_uri
	){
		var oJWT          = getOJWT();
		var dateIssued    = now();
		var dateExpires   = dateAdd( 's', 30, dateIssued );
		var stuPayload = {
			'sub': arguments.userId,
			'aud': arguments.clientId,
			'redirect_uri': arguments.redirect_uri,
			'iat': createEpoch( dateIssued ),
			'exp': createEpoch( dateExpires )
		};
		return oJWT.encode( stuPayload );
	}


	/**
	* A shorthand to access the JWT decode method.
	* @jwt The JWT to decode
	*/
	function decode( required string jwt ){
		return getOJWT().decode( jwt );
	}


	/**
	* Create epoch time
	* @date The string date time value to convert
	*/
	function createEpoch( required string date ){
		return dateDiff( 's', dateConvert( "utc2Local", "January 1 1970 00:00" ), arguments.date );
	}

	/**
	* Returns the properties as a struct
	*/
	public struct function getMemento(){
		var result = {};
		for( var thisProp in getMetaData( this ).properties ){
			if( structKeyExists( variables, thisProp[ 'name' ] ) ){
				result[ thisProp[ 'name' ] ] = variables[ thisProp[ 'name' ] ];
			}
		}
		return result;
	}


}