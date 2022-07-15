## Verify Deployment

1. Download test access token from [here](http://cis-services-l1.ute.fedex.com:7001/authn/rs/o2b/token/access/test).

> **Note**
>
> It will attempt to download a JWT (access token) with a file called **test**.
> One may have to copy the link and open it in a new tab!

2. Go to application Swagger UI [here](http://c0032643.test.cloud.fedex.com:8001/audit).
3. Authorize, entering jwt_token value as **Bearer &lt;token&gt;**, where **&lt;token&gt;** was downloaded in step 1.

For example:

```
Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ0ZXN0IiwiYXVkIjpbIk8yQiIsIkEyQiIsIkIyQiIsIkMyQiJdLCJ0cnUiOmZhbHNlLCJraWQiOiJQUDQ4UUVDYjFTdFBualFPbFo0V2lfdlF3WjdfYkhHakp6SFRHaWFfbEhRIiwiaXNzIjoiY2lzLWF1dGhuLWwxIiwiZXhwIjoxNjIzODY5NzIyLCJpYXQiOjE2MjM4Njg4MjIsImp0aSI6IjI2NDNkYjc3LTczMWMtNGJhZi05Mjc1LTZlYjI4MjllMTNjNSJ9.O-wzxHcXz3GeO6f6hsOjn-iCrzmb3zDPe-Uwu9xTyQWaO3pXU4kbI3AaLgJYUS3_2qpZIq--_4mELMtUxAG_lrDnUhj4ZO67RVK0V6hDLaBH9XiB24PqACHEt0i6FRbF-NSBt77UVx9860VNlXqnr2e-24fz0a5QJ2P4bYzpbDwOQzC_AlNSDMzVszCw0xXpt9Ubh6VHTnoXpphIwwhsUUVN02ZssXxwEg7vYiMqpURx1hoWxYZejFWTPyoiU5idoMiUxB0H0LHWKMcFeVi28N91UTX6Nrthfz1dQrkRTXS2PupTkjX2XNeuPoX92aerWLv3a7Nb339My8oDekJnNQ
```

> **Note**
>
> Bearer is case sensitive!

4. Try out the /c2b/v2/query POST request as follows:

* Ensure both Parameter and Response content types are application/xml
* Enter the following body:

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<query>
  <relationship>AND</relationship>
  <filter xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="principalFilter">
    <operator>EQUAL</operator>
    <text>474768</text>
  </filter>
  <filter xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="conductedFilter">
    <operator>EQUAL</operator>
    <from>2020-02-12T00:00:00Z</from>
    <to>2020-02-14T23:59:59.999Z</to>
  </filter>
</query>
```

* Finally, Execute

> **Note**
>
> If you get a Unauthorized response, download another test token!
