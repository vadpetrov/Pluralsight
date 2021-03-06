
/****** Object:  Table [dbo].[CacheState]    Script Date: 07/25/2012 13:38:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CacheState]') AND type in (N'U'))
DROP TABLE [dbo].[CacheState]
GO


/****** Object:  Table [dbo].[CacheState]    Script Date: 07/25/2012 13:38:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CacheState](
	[CacheKeyHash] [binary](20) NOT NULL,
	[RoutePattern] [nvarchar](256) NOT NULL,
	[ResourceUri] [nvarchar](256) NOT NULL,
	[ETag] [nvarchar](100) NOT NULL,
	[LastModified] [datetime] NOT NULL,
 CONSTRAINT [PK_CacheState] PRIMARY KEY CLUSTERED 
(
	[CacheKeyHash] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_AddUpdateCache]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].Server_AddUpdateCache
GO

-- =============================================
-- Author:		Ali Kheyrollahi
-- Create date: 2012-07-12
-- Description:	Adds or updates cache entry
-- =============================================
CREATE PROCEDURE Server_AddUpdateCache
	@cacheKeyHash	BINARY(20),
	@routePattern	NVARCHAR(256),
	@resourceUri	NVARCHAR(256),
	@eTag			NVARCHAR(100),
	@lastModified	DATETIME
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	BEGIN TRAN
	IF EXISTS (SELECT 1 FROM dbo.CacheState 
			WITH (UPDLOCK,SERIALIZABLE) WHERE CacheKeyHash = @cacheKeyHash)
		BEGIN
			UPDATE dbo.CacheState SET 
					ETag = @eTag,
					LastModified = @lastModified,
					RoutePattern = @routePattern,
					ResourceUri	 = @resourceUri
				WHERE CacheKeyHash = @cacheKeyHash
		END
	ELSE
	
		BEGIN
			INSERT INTO dbo.CacheState 
				(CacheKeyHash, RoutePattern, ResourceUri, ETag, LastModified)
			values 
				(@cacheKeyHash, @routePattern, @resourceUri, @eTag, @lastModified)
		END
	COMMIT TRAN

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_ClearCache]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Server_ClearCache]
GO

-- =============================================
-- Author:		Carl Duguay
-- Create date:	2013-07-10
-- Description:	Removes all CacheKey records
-- =============================================
CREATE PROCEDURE Server_ClearCache	 
AS
BEGIN
	SET NOCOUNT OFF
	DELETE FROM [dbo].[CacheState]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_DeleteCacheById]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Server_DeleteCacheById]
GO

-- =============================================
-- Author:		Ali Kheyrollahi
-- Create date: 2012-07-12
-- Description:	Deletes a CacheKey record by its id
-- =============================================
CREATE PROCEDURE Server_DeleteCacheById
	@CacheKeyHash BINARY(20) 
AS
BEGIN
	SET NOCOUNT OFF
	DELETE FROM dbo.CacheState WHERE CacheKeyHash = @CacheKeyHash
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_DeleteCacheByResourceUri]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].Server_DeleteCacheByResourceUri
GO

-- =============================================
-- Author:		Ali Kheyrollahi
-- Create date: 2013-11-16
-- Description:	Deletes all CacheKey records by its resource uri
-- =============================================
CREATE PROCEDURE Server_DeleteCacheByResourceUri
	@resourceUri NVARCHAR(256) 
AS
BEGIN
	SET NOCOUNT OFF

	DELETE FROM dbo.CacheState WHERE ResourceUri = @resourceUri
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_DeleteCacheByRoutePattern]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].Server_DeleteCacheByRoutePattern
GO

-- =============================================
-- Author:		Ali Kheyrollahi
-- Create date: 2012-07-12
-- Description:	Deletes all CacheKey records by its route pattern
-- =============================================
CREATE PROCEDURE Server_DeleteCacheByRoutePattern
	@routePattern NVARCHAR(256) 
AS
BEGIN
	SET NOCOUNT OFF

	DELETE FROM dbo.CacheState WHERE RoutePattern = @routePattern
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Server_GetCache]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].Server_GetCache
GO

-- =============================================
-- Author:		Ali Kheyrollahi
-- Create date: 2012-07-12
-- Description:	returns cache entry by its Id
-- =============================================
CREATE PROCEDURE Server_GetCache
	@cacheKeyHash		BINARY(20)
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		ETag, LastModified
	FROM
		dbo.CacheState
	WHERE
		CacheKeyHash = @cacheKeyHash

END
GO
