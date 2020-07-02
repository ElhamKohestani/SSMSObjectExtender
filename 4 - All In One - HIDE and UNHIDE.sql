

 -- CREATE PROC hide

CREATE procedure [dbo].[ekt_sp_HideObjectsInObjectExplorer](@schemaName nvarchar(200), @objectName nvarchar(200), @HideOjbectWithExactName bit)
as
begin

	-- declare table of objects which are to be hidden.
	declare @tableOfObjects as table (id int identity(1,1),schemaName nvarchar(200), objectName nvarchar(200));
	
	if @HideOjbectWithExactName = 1
	begin
		
		-- Get the exact object name which doesn't have the exetended property of Hide.
		insert into @tableOfObjects (schemaName, objectName)
		select sc.[name], t.[name] from sys.tables t
		left join sys.schemas sc
		on sc.schema_id = t.schema_id

		where 
		sc.[name] =@schemaName
		and t.[object_id] not in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')
		and t.[name] = @objectName; -- like   '%'+N'Book'+'%'
	end
	else
	begin
		insert into @tableOfObjects (schemaName, objectName)
		select sc.[name], t.[name] from sys.tables t
		left join sys.schemas sc
		on sc.schema_id = t.schema_id

		where 
		sc.[name] = @schemaName
		and t.[object_id] not in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')
		and t.[name]  like   '%'+@objectName+'%'
	end


	declare @loopCounter int, @noOfObjects int, @currId int;
	-- configure the loop
	set @loopCounter = 1;
	select @noOfObjects = count(*) from @tableOfObjects
	select @currId = min(id) from @tableOfObjects;



	while @loopCounter <= @noOfObjects
	begin
	
		declare @currObjectName nvarchar(200); select @currObjectName = objectName  from @tableOfObjects where id = @currId;
		declare @currSchemaName nvarchar(200); select @currSchemaName = schemaName from @tableOfObjects where id = @currId;
		exec sp_addextendedproperty
		@name = N'microsoft_database_tools_support',
		@value = 'Hide',
		@level0type = N'Schema', @level0name = @currSchemaName,
		@level1type = N'Table', @level1name = @currObjectName;


		set @currId = @currId + 1;
		set @loopCounter = @loopCounter + 1;
	end
	
end
GO

-- CREATE PROC unhide


CREATE procedure [dbo].[ekt_sp_UnHideObjectsInObjectExplorer](@schemaName nvarchar(200), @objectName nvarchar(200), @HideOjbectWithExactName bit)
as
begin

	-- declare table of objects which are to be hidden.
	declare @tableOfObjects as table (id int identity(1,1),schemaName nvarchar(200), objectName nvarchar(200));
	
	if @HideOjbectWithExactName = 1
	begin
		
		-- Get the exact object name which doesn't have the exetended property of Hide.
		insert into @tableOfObjects (schemaName, objectName)
		select sc.[name], t.[name] from sys.tables t
		left join sys.schemas sc
		on sc.schema_id = t.schema_id

		where 
		sc.[name] =@schemaName
		and t.[object_id]  in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')
		and t.[name] = @objectName; -- like   '%'+N'Book'+'%'
	end
	else
	begin
		insert into @tableOfObjects (schemaName, objectName)
		select sc.[name], t.[name] from sys.tables t
		left join sys.schemas sc
		on sc.schema_id = t.schema_id

		where 
		sc.[name] = @schemaName
		and t.[object_id]  in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')
		and t.[name]  like   '%'+@objectName+'%'
	end


	declare @loopCounter int, @noOfObjects int, @currId int;
	-- configure the loop
	set @loopCounter = 1;
	select @noOfObjects = count(*) from @tableOfObjects
	select @currId = min(id) from @tableOfObjects;



	while @loopCounter <= @noOfObjects
	begin
	
		declare @currObjectName nvarchar(200); select @currObjectName = objectName  from @tableOfObjects where id = @currId;
		declare @currSchemaName nvarchar(200); select @currSchemaName = schemaName from @tableOfObjects where id = @currId;
		

		EXEC sp_dropextendedproperty   
		 @name =  N'microsoft_database_tools_support'  
		,@level0type = 'Schema'   
		,@level0name = @currSchemaName
		,@level1type = 'Table'  
		,@level1name = @currObjectName;
		set @currId = @currId + 1;
		set @loopCounter = @loopCounter + 1;
	end
	
end
GO





-- GET All Hidden tables
select * from sys.tables
where object_id in (select major_id from sys.extended_properties where [value] = 'Hide' and [name] = 'microsoft_database_tools_support')


-- Unhide and unhide specific tables


exec dbo.ekt_sp_HideObjectsInObjectExplorer N'dbo', N'', 1; -- IF 1 then the procedure will hide the table with the exact name as the parameter. If 0 then it will use like
exec dbo.ekt_sp_UnHideObjectsInObjectExplorer N'dbo', N'Lib', 0;


drop proc dbo.ekt_sp_HideObjectsInObjectExplorer;

drop proc dbo.ekt_sp_UnHideObjectsInObjectExplorer;



