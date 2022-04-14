--DATA CLEANING IN SQL

--Preview the Data
SELECT *
FROM [Brasvile Housing Data]

--STANDARDISiNG DATE FORMAT

ALTER TABLE [Brasvile Housing Data]
Add SalesDateConverted date;

UPDATE [Brasvile Housing Data]
SET SalesDateConverted = CONVERT(date,SaleDate)


--POPULATING NULL PROPERTY ADDRESS

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Brasvile Housing Data] A
JOIN [Brasvile Housing Data] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Brasvile Housing Data] A
JOIN [Brasvile Housing Data] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address,City,State)

SELECT *
FROM [Brasvile Housing Data]
--PROPERTY ADDRESS
SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM [Brasvile Housing Data]

ALTER TABLE [Brasvile Housing Data]
Add PropertySplitAddress NVarchar(255);

UPDATE [Brasvile Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE [Brasvile Housing Data]
Add PropertySplitCity NVarchar(255);

UPDATE [Brasvile Housing Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

-- BREAKING OWNER ADDRESS INTO 3 COLUMNS 
SELECT OwnerAddress
FROM [Brasvile Housing Data]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM [Brasvile Housing Data]

ALTER TABLE [Brasvile Housing Data]
Add OwnerSplitAddress NVarchar(255);

UPDATE [Brasvile Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE [Brasvile Housing Data]
Add OwnerSplitCity NVarchar(255);

UPDATE [Brasvile Housing Data]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE [Brasvile Housing Data]
Add OwnerSplitState NVarchar(255);

UPDATE [Brasvile Housing Data]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

--CHANGING Y & N TO YES & NO

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM [Brasvile Housing Data]

UPDATE [Brasvile Housing Data]
SET SoldAsVacant=CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

--REMOVE DUPLICATES 

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
ParcelID, PropertyAddress, Saleprice, SaleDate, LegalReference ORDER BY UniqueID) row_numb
FROM [Brasvile Housing Data]
)

DELETE
FROM RowNumCTE
WHERE row_numb > 1
--Checking if delete is effected (run with CTE by commenting out delete queries)
SELECT *
FROM RowNumCTE
WHERE row_numb > 1
ORDER BY PropertyAddress

--DELETE UNWANTED COLUMNS 

ALTER TABLE [Brasvile Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
