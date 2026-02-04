require 'digest'

module Jekyll
  # Liquid tag to generate fingerprinted asset URLs
  # Usage: {% fingerprint /assets/main.css %}
  class FingerprintTag < Liquid::Tag
    def initialize(tag_name, path, tokens)
      super
      @path = path.strip
    end

    def render(context)
      site = context.registers[:site]
      path = Liquid::Template.parse(@path).render(context).strip

      # Remove leading slash for file lookup
      relative_path = path.sub(/^\//, '')

      # Try to find the file in the source directory
      source_file = File.join(site.source, relative_path)

      if File.exist?(source_file)
        content = File.read(source_file)
        hash = Digest::MD5.hexdigest(content)[0, 8]

        # Generate fingerprinted filename
        ext = File.extname(path)
        base = path.chomp(ext)
        "#{base}-#{hash}#{ext}"
      else
        # Return original path if file not found
        path
      end
    end
  end

  # Generator to create fingerprinted copies of assets
  class FingerprintGenerator < Generator
    safe true
    priority :low

    FINGERPRINT_EXTENSIONS = %w[.css .js].freeze

    def generate(site)
      fingerprinted_files = []

      site.static_files.each do |file|
        next unless FINGERPRINT_EXTENSIONS.include?(File.extname(file.path))

        # Read file content and compute hash
        content = File.read(file.path)
        hash = Digest::MD5.hexdigest(content)[0, 8]

        # Create fingerprinted static file
        fingerprinted_files << FingerprintedStaticFile.new(
          site,
          site.source,
          file.relative_path.sub(/^\//, '').sub(file.name, ''),
          file.name,
          hash
        )
      end

      site.static_files.concat(fingerprinted_files)
    end
  end

  # Custom static file that outputs with a fingerprinted name
  class FingerprintedStaticFile < StaticFile
    def initialize(site, base, dir, name, hash)
      super(site, base, dir, name)
      @hash = hash
    end

    def destination_rel_dir
      @collection&.relative_directory || @dir
    end

    def destination(dest)
      ext = File.extname(@name)
      base = @name.chomp(ext)
      fingerprinted_name = "#{base}-#{@hash}#{ext}"

      File.join(dest, destination_rel_dir, fingerprinted_name)
    end
  end
end

Liquid::Template.register_tag('fingerprint', Jekyll::FingerprintTag)
