USE [Maiwand_MIS]
GO

/****** Object:  StoredProcedure [dbo].[ekt_sp_UnHideObjectsInObjectExplorer]    Script Date: 12/18/2018 7:53:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


