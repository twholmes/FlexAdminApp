			DECLARE @ResourceString NVARCHAR(256)
			SET @ResourceString = 'AccessMode.AppVolumes'

			DECLARE @ResourceValue NVARCHAR(256)
			SET @ResourceValue = 'App Volumes'



			IF NOT EXISTS (SELECT 1 FROM ComplianceResourceString WHERE ResourceString = @ResourceString)
			BEGIN
				INSERT INTO ComplianceResourceString (ResourceString)
				VALUES (@ResourceString)
			END


			IF NOT EXISTS (SELECT 1 FROM ResourceStringCultureType WHERE ResourceString = @ResourceString)
			BEGIN
				INSERT INTO ResourceStringCultureType (CultureType, ResourceString, ResourceValue)
				VALUES ('en-US', @ResourceString, @ResourceValue)
			END

			DECLARE @AccessModeID INT
			SET @AccessModeID = 1000
			DECLARE @msg NVARCHAR(MAX)

			IF NOT EXISTS (SELECT 1 FROM AccessMode WHERE ResourceName = @ResourceString)
			BEGIN
				SET @msg = 'Adding new AccessMode "' + @ResourceString + '" with ID "' + CONVERT(NVARCHAR(10), @AccessModeID) + '"'
				PRINT @msg

				IF EXISTS (SELECT 1 FROM AccessMode WHERE AccessModeID = @AccessModeID)
				BEGIN
					SET @msg = 'An access mode with ID ' + CONVERT(NVARCHAR(10), @AccessModeID) + ' already exists.'
					RAISERROR(@msg,16,1)
				END

				SET IDENTITY_INSERT AccessMode ON
				INSERT INTO AccessMode (AccessModeID, ResourceName, DefaultValue)
				VALUES (@AccessModeID, @ResourceString, @ResourceValue)
				SET IDENTITY_INSERT AccessMode OFF
		END