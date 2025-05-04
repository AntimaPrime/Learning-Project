-- Cleaning data in SQL Queries

SELECT *
from [Portfolio Project]..nashville_home_data

--Standardize Data Format

select saledate, convert(date,saledate)
from [Portfolio Project]..nashville_home_data
 
alter table [Portfolio Project]..nashville_home_data
add SaleDate1 date;

update [Portfolio Project]..nashville_home_data
set SaleDate1 = convert(Date, SaleDate)

alter table [Portfolio Project]..nashville_home_data
drop column SaleDate

--Populate property address data

select *
from [Portfolio Project]..nashville_home_data
--where propertyaddress is null
order by parcelid

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..nashville_home_data a
join [Portfolio Project]..nashville_home_data b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..nashville_home_data a
join [Portfolio Project]..nashville_home_data b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Break address into individual columns (address, city, state)

-- Using substrings

select *
from [Portfolio Project]..nashville_home_data

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from [Portfolio Project]..Nashville_Home_Data

alter table [Portfolio Project]..nashville_home_data
add PropertyAddress1 nvarchar(255);

alter table [Portfolio Project]..nashville_home_data
add City nvarchar(255);

update [Portfolio Project]..nashville_home_data
set PropertyAddress1 = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

update [Portfolio Project]..nashville_home_data
set City = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

-- Using parsename

select OwnerAddress
from [Portfolio Project]..Nashville_Home_Data

select
parsename(replace(OwnerAddress, ',', '.'), 3) as OwnerAddress1,
parsename(replace(OwnerAddress, ',', '.'), 2) as OwnerCity1,
parsename(replace(OwnerAddress, ',', '.'), 1) as OwnerState1
from [Portfolio Project]..Nashville_Home_Data


alter table [Portfolio Project]..nashville_home_data
add OwnerAddress1 nvarchar(255);

alter table [Portfolio Project]..nashville_home_data
add OwnerCity1 nvarchar(255);

alter table [Portfolio Project]..nashville_home_data
add OwnerState1 nvarchar(255);

update [Portfolio Project]..nashville_home_data
set OwnerAddress1 = parsename(replace(OwnerAddress, ',', '.'), 3)

update [Portfolio Project]..nashville_home_data
set OwnerCity1 = parsename(replace(OwnerAddress, ',', '.'), 2)

update [Portfolio Project]..nashville_home_data
set OwnerState1 = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from [Portfolio Project]..nashville_home_data

--Change y and n to yes and no in "SoldAsVacant" category

select distinct(SoldAsVacant),  count(SoldAsVacant)
from [Portfolio Project]..nashville_home_data
group by SoldAsVacant
order by 2

select SoldAsVacant
, case	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		end
from [Portfolio Project]..nashville_home_data

update [Portfolio Project]..Nashville_Home_Data
set SoldAsVacant = case	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over (
	partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
						UniqueID
						) row_num
				
from [Portfolio Project]..nashville_home_data
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1

--delete unused columns

select *
from [Portfolio Project]..Nashville_Home_Data

alter table [Portfolio Project]..Nashville_Home_Data
drop column OwnerAddress, TaxDistrict, PropertyAddress
