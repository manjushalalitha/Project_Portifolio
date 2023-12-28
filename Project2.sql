
/*

Cleaning Data in SQL Queries

*/

-- Checking the data 
select * from nashvillehousing where Propertyaddress is null;
-- Setting date to date format
select * from nashvillehousing;
ALTER TABLE nashvillehousing
MODIFY COLUMN SaleDate DATE;
UPDATE nashvillehousing
SET SaleDate = Saledate;
-- Generating PropertyAddress Data by merging
SELECT
    a.ParcelId,
    a.PropertyAddress,
    b.ParcelId AS b_ParcelId,
    b.PropertyAddress AS b_PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress) 
FROM
    Nashvillehousing a
JOIN
    nashvillehousing b ON a.ParcelId = b.ParcelId AND a.UniqueId <> b.UniqueId
WHERE
    a.PropertyAddress IS NULL;
 -- Dividing Address into individual addresses
select PropertyAddress from NashvilleHousing ;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1),Length(PropertyAddress) AS Address
FROM 
    NashvilleHousing;
Alter Table nashvillehousing add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);
Alter table NashvilleHousing
Add PropertySplitCity NVarchar(255);
Update NashvilleHousing Set PropertySplitCity =SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress) + 1);

SELECT SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) ,SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2),SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3)
FROM NashvilleHousing;
SELECT SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1),SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1),SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1)
FROM NashvilleHousing;

-- SELECT 
--     SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS SecondPart
-- FROM 
--     NashvilleHousing;
   --  select * from NashvilleHousing;
    
Alter Table nashvillehousing add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing set OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1);
Alter table NashvilleHousing Add OwnerSplitCity NVarchar(255);
Update NashvilleHousing Set OwnerSplitCity =SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);
Alter table NashvilleHousing Add OwnerSplitState NVarchar(255);
Update NashvilleHousing Set OwnerSplitState=SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1);

-- Change Y and N to yes and no for a column 
SELECT soldasvacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant
FROM 
    NashvilleHousing;
    
Update NashvilleHousing set SoldasVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
		END;
 --  select SoldAsVacant from NashvilleHousing
 select distinct SOldAsVacant ,Count(SOldAsVacant) from NashvilleHousing group by SoldasVacant order by SoldAsVacant;
 
 -- Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY
                UniqueID
        ) AS row_num
    FROM NashvilleHousing
    
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

