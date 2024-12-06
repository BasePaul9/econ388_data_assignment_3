/*
Data Assignment 3

Creator: {Paul Morrison}
Date: {12/06/2024}
Inputs: 
	- chat.dta #Tech progress
	- pwt1001.dta #GDP per capita
*/


clear

cd "C:\Users\pem29\Box\ECON 388\Data Assignment 3"

cap log close
log using Data_Assignment_3.log, replace

// Data wrangling for tech progress data
use chat.dta

gen country = country_name, after(country_name)
replace country = "Bosnia and Herzegovina" if country == "Bosnia-Herzegovina"
replace country = "Republic of Korea" if country == "South Korea"
replace country = "Myanmar" if country == "Burma"

keep country year ag_tractor atm computer newspaper transplant_kidney vehicle_car

save NBER_data, replace
clear

// Data wrangling for GDP data
use pwt1001.dta

replace country = "Bolivia" if country == "Bolivia (Plurinational State of)"
replace country = "Democratic Republic of the Congo" if country == "D.R. of the Congo"
replace country = "Hong Kong" if country == "China, Hong Kong SAR"
replace country = "Iran" if country == "Iran (Islamic Republic of)"
replace country = "Laos" if country == "Lao People's DR"
replace country = "Moldova" if country == "Republic of Moldova"
replace country = "Russia" if country == "Russian Federation"
replace country = "Slovak Republic" if country == "Slovakia"
replace country = "Syria" if country == "Syrian Arab Republic"
replace country = "Venezuela" if country == "Venezuela (Bolivarian Republic of)"
replace country = "Vietnam" if country == "Viet Nam"

keep country year rgdpe pop emp avh pl_c xr csh_g
drop if year < 1970
drop if year > 1999

gen gdp_per_cap = (rgdpe/pop), after(pop)
replace emp = emp/pop

// Merge datasets
merge 1:1 country year using NBER_data
tab _m
drop if _m != 3
drop _m

//Expand values
reshape wide rgdpe pop gdp_per_cap emp avh pl_c xr csh_g ag_tractor atm computer newspaper transplant_kidney vehicle_car, i(country) j(year)

// Generate growth rates
forvalues i = 1970/1998 {
	local j = `i' + 1
	gen rgdpe_growth`i' = ((rgdpe`j' / rgdpe`i') - 1) * 100
	gen pop_growth`i' = ((pop`j' / pop`i') - 1) * 100
	gen gdp_per_cap_growth`i' = ((gdp_per_cap`j' / gdp_per_cap`i') - 1) * 100
	gen emp_growth`i' = ((emp`j' / emp`i') - 1) * 100
	gen avh_growth`i' = ((avh`j' / avh`i') - 1) * 100
	gen pl_c_growth`i' = ((pl_c`j' / pl_c`i') - 1) * 100
	gen xr_growth`i' = ((xr`j' / xr`i') - 1) * 100
	gen csh_g_growth`i' = ((csh_g`j' / csh_g`i') - 1) * 100
	gen ag_tractor_growth`i' = ((ag_tractor`j' / ag_tractor`i') - 1) * 100
	gen atm_growth`i' = ((atm`j' / atm`i') - 1) * 100
	gen computer_growth`i' = ((computer`j' / computer`i') - 1) * 100
	gen newspaper_growth`i' = ((newspaper`j' / newspaper`i') - 1) * 100
	gen transplant_kidney_growth`i' = ((transplant_kidney`j' / transplant_kidney`i') - 1) * 100
	gen vehicle_car_growth`i' = ((vehicle_car`j' / vehicle_car`i') - 1) * 100
}

// Contract values into long form
reshape long rgdpe rgdpe_growth pop pop_growth gdp_per_cap gdp_per_cap_growth emp avh pl_c xr csh_g emp_growth avh_growth pl_c_growth xr_growth csh_g_growth ag_tractor ag_tractor_growth atm atm_growth computer computer_growth newspaper newspaper_growth transplant_kidney transplant_kidney_growth vehicle_car vehicle_car_growth, i(country) j(year)

// Generate binary for whether a country is developed
gen developed = country == "France" | country == "Germany" | country == "Italy" | country == "Japan" |country ==  "United Kingdom" | country == "United States", after(year)

save master_data, replace

// Analysis part 1 - Growth Rates

// Controls as growth rates:
// All Tech  + controls 
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Newspaper significant

// Tech only
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth // No significance

// Tractor + controls
reg gdp_per_cap_growth ag_tractor_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Significant at 5% level, p = 0.023

// ATM + controls
reg gdp_per_cap_growth atm_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Not significant

// Computer + controls
reg gdp_per_cap_growth computer_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Not significant

// Newspaper + controls
reg gdp_per_cap_growth newspaper_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Not significant

// Kidney Transplant + controls
reg gdp_per_cap_growth transplant_kidney_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Significant, p = 0.009

// Car + controls
reg gdp_per_cap_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // Significant, p < 0.001

//Sig factors
reg gdp_per_cap_growth ag_tractor_growth newspaper_growth transplant_kidney_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth // all but tractor significant


// Analysis part 2 - Development

// All Tech  + controls 
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1 
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// Tech only
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth if developed == 1 
reg gdp_per_cap_growth ag_tractor_growth atm_growth computer_growth newspaper_growth transplant_kidney_growth vehicle_car_growth if developed == 0

// Tractor + controls
reg gdp_per_cap_growth ag_tractor_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth ag_tractor_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// ATM + controls
reg gdp_per_cap_growth atm_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth atm_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// Computer + controls
reg gdp_per_cap_growth computer_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth computer_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// Newspaper + controls
reg gdp_per_cap_growth newspaper_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth newspaper_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// Kidney Transplant + controls
reg gdp_per_cap_growth transplant_kidney_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth transplant_kidney_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0

// Car + controls
reg gdp_per_cap_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 1
reg gdp_per_cap_growth vehicle_car_growth emp_growth avh_growth pl_c_growth xr_growth csh_g_growth if developed == 0


log close