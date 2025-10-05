local M = {}

-- Define Java file prototypes
M.prototypes = {
    class = [[
package %s;

public class %s {
    public %s() {
        // Constructor
    }
}
]],
    interface = [[
package %s;

public interface %s {
    // Interface methods
}
]],
    enum = [[
package %s;

public enum %s {
    // Enum values
}
]]
}

-- Function to create a new Java file
M.create_java_file = function()
    -- Prompt for file type
    local file_type = vim.fn.input("Enter type (class/interface/enum): "):lower()
    if not M.prototypes[file_type] then
        print("Invalid type. Choose from class, interface, or enum.")
        return
    end

    -- Prompt for package name
    local package_name = vim.fn.input("Enter package name (e.g., com.example): ")

    -- Prompt for file name
    local file_name = vim.fn.input("Enter file name (without extension): ")

    -- Generate file content
    local content = string.format(M.prototypes[file_type], package_name, file_name, file_name)

    -- Create the file
    local file_path = string.format("%s/%s.java", vim.fn.getcwd(), file_name)
    local file = io.open(file_path, "w")
    if file then
        file:write(content)
        file:close()
        print("File created: " .. file_path)
        vim.cmd("edit " .. file_path) -- Open the file in Neovim
    else
        print("Failed to create file.")
    end
end

-- Register the command
vim.api.nvim_create_user_command("NewJavaFile", M.create_java_file, {})

return {}
