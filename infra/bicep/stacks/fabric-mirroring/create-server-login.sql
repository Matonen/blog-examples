CREATE LOGIN [sp-fabric-sql-statereader] FROM EXTERNAL PROVIDER;
ALTER SERVER ROLE [##MS_ServerStateReader##] ADD MEMBER [sp-fabric-sql-statereader];
