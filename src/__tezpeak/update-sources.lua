-- tezpeak SOURCE: https://github.com/tez-capital/tezpeak/releases
-- arc SOURCE: https://github.com/alis-is/arc-releases/releases
-- usage:
-- eli src/__tezpeak/update-sources.lua

local hjson = require "hjson"

local http_options = nil

--------------------------------------------------------------------------------
-- GitHub Fetching Helper
--------------------------------------------------------------------------------

local function fetch_github_release(repo)
	print("Fetching releases from " .. repo .. "...")
	local url = "https://api.github.com/repos/" .. repo .. "/releases"
	local response = net.download_string(url, http_options)

	if #response == 0 then
		print("Empty response from " .. repo)
		return nil
	end

	local releases = hjson.parse(response)
	if not releases or #releases == 0 then
		return nil
	end

	return releases[1]
end

local function extract_asset(release, name_pattern)
	if not release or not release.assets then return nil end
	for _, asset in ipairs(release.assets) do
		if asset.name:match(name_pattern) then
			local hash = nil
			if asset.digest then
				hash = asset.digest:match("sha256:(%x+)")
			end
			return {
				url = asset.browser_download_url,
				sha256 = hash,
				version = release.tag_name
			}
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Fetch Releases
--------------------------------------------------------------------------------

-- 1. Tezpeak (Latest)
local tezpeak_release = fetch_github_release("tez-capital/tezpeak")
if tezpeak_release then
	print("Found Tezpeak release: " .. tezpeak_release.tag_name)
else
	print("Warning: Failed to fetch Tezpeak release")
end

-- 2. Arc (Latest)
local arc_release = fetch_github_release("alis-is/arc-releases")
if arc_release then
	print("Found Arc release: " .. arc_release.tag_name)
else
	print("Warning: Failed to fetch Arc release")
end

--------------------------------------------------------------------------------
-- Update Sources
--------------------------------------------------------------------------------

local current_sources = hjson.parse(fs.read_file("src/__tezpeak/sources.hjson"))
local new_sources_map = {}

local platforms = {
	["linux-x86_64"] = {
		tezpeak_pattern = "tezpeak%-linux%-amd64",
		arc_pattern = "arc%-x86_64%-unknown%-linux%-musl"
	},
	["linux-arm64"] = {
		tezpeak_pattern = "tezpeak%-linux%-arm64",
		arc_pattern = "arc%-aarch64%-unknown%-linux%-musl"
	},
	["darwin-arm64"] = {
		tezpeak_pattern = "tezpeak%-macos%-arm64"
		-- arc not available for macOS
	}
}

for platform, config in pairs(platforms) do
	print("Updating " .. platform .. "...")
	local new_platform_sources = {}

	-- 1. Tezpeak
	if tezpeak_release then
		local tezpeak_data = extract_asset(tezpeak_release, config.tezpeak_pattern)
		if tezpeak_data then
			new_platform_sources.tezpeak = tezpeak_data
		else
			print("  Warning: Tezpeak asset matching " .. config.tezpeak_pattern .. " not found")
			if current_sources[platform] and current_sources[platform].tezpeak then
				new_platform_sources.tezpeak = current_sources[platform].tezpeak
			end
		end
	else
		if current_sources[platform] and current_sources[platform].tezpeak then
			new_platform_sources.tezpeak = current_sources[platform].tezpeak
		end
	end

	-- 2. Arc (Linux only)
	if config.arc_pattern then
		if arc_release then
			local arc_data = extract_asset(arc_release, config.arc_pattern)
			if arc_data then
				new_platform_sources.arc = arc_data
			else
				print("  Warning: Arc asset matching " .. config.arc_pattern .. " not found")
				if current_sources[platform] and current_sources[platform].arc then
					new_platform_sources.arc = current_sources[platform].arc
				end
			end
		else
			if current_sources[platform] and current_sources[platform].arc then
				new_platform_sources.arc = current_sources[platform].arc
			end
		end
	end

	new_sources_map[platform] = new_platform_sources
end

-- Preserve any platforms not in our list
for k, v in pairs(current_sources) do
	if not new_sources_map[k] then
		new_sources_map[k] = v
	end
end

local new_content = "// tezpeak SOURCE: https://github.com/tez-capital/tezpeak/releases \n" ..
	"// arc SOURCE: https://github.com/alis-is/arc-releases/releases \n"
new_content = new_content .. hjson.stringify(new_sources_map, { separator = true, sort_keys = true })

fs.write_file("src/__tezpeak/sources.hjson", new_content)
print("Updated src/__tezpeak/sources.hjson")
