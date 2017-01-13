# MIME Types for Crystal [![Build Status](https://travis-ci.org/jwaldrip/promise-cr.svg?branch=master)](https://travis-ci.org/jwaldrip/promise.cr) [![GitHub release](https://img.shields.io/github/release/jwaldrip/promise-cr.svg)](https://github.com/jwaldrip/promise.cr/releases) [![Crystal Docs](https://img.shields.io/badge/Crystal-Docs-8A2BE2.svg)](https://jwaldrip.github.com/promise.cr)

## Description

The mime-types library provides a library and registry for information about
MIME content type definitions. It can be used to determine defined filename
extensions for MIME types, or to use filename extensions to look up the likely
MIME type definitions.

### About MIME Media Types

MIME content types are used in MIME-compliant communications, as in e-mail or
HTTP traffic, to indicate the type of content which is transmitted. The
mime-types library provides the ability for detailed information about MIME
entities (provided as an enumerable collection of MIME::Type objects) to be
determined and used. There are many types defined by RFCs and vendors, so the
list is long but by definition incomplete; don't hesitate to add additional
type definitions. MIME type definitions found in mime-types are from RFCs, W3C
recommendations, the (IANA Media Types
registry)[https://www.iana.org/assignments/media-types/media-types.xhtml], and
user contributions. It conforms to RFCs 2045 and 2231.

## Synopsis

MIME types are used in MIME entities, as in email or HTTP traffic. It is useful
at times to have information available about MIME types (or, inversely, about
files). A MIME::Type stores the known information about one MIME type.

```
require "mime/types"

plaintext = MIME::Types["text/plain"] # => [ text/plain ]
text = plaintext.first
puts text.media_type            # => "text"
puts text.sub_type              # => "plain"

puts text.extensions.join(' ')  # => "txt asc c cc h hh cpp hpp dat hlp"
puts text.preferred_extension   # => "txt"
puts text.friendly              # => "Text Document"
puts text.i18n_key              # => "text.plain"

puts text.encoding              # => quoted-printable
puts text.default_encoding      # => quoted-printable
puts text.binary?               # => false
puts text.ascii?                # => true
puts text.obsolete?             # => false
puts text.registered?           # => true
puts text.complete?             # => true

puts text                       # => "text/plain"

puts text == "text/plain"       # => true
puts "text/plain" == text       # => true
puts text == "text/x-plain"     # => false
puts "text/x-plain" == text     # => false

puts MIME::Type.simplified("x-appl/x-zip") # => "x-appl/x-zip"
puts MIME::Type.i18n_key("x-appl/x-zip") # => "x-appl.x-zip"

puts text.like?("text/x-plain") # => true
puts text.like?(MIME::Type.new("x-text/x-plain")) # => true

puts text.xref_urls
# => [ "http://www.iana.org/go/rfc2046",
#      "http://www.iana.org/go/rfc3676",
#      "http://www.iana.org/go/rfc5147" ]

xtext = MIME::Type.new("x-text/x-plain")
puts xtext.media_type # => "text"
puts xtext.raw_media_type # => "x-text"
puts xtext.sub_type # => "plain"
puts xtext.raw_sub_type # => "x-plain"
puts xtext.complete? # => false

puts MIME::Types.any? { |type| type.content_type == "text/plain" } # => true
puts MIME::Types.all?(&.registered?) # => false

# Various string representations of MIME types
qcelp = MIME::Types["audio/QCELP"].first # => audio/QCELP
puts qcelp.content_type         # => "audio/QCELP"
puts qcelp.simplified           # => "audio/qcelp"

xwingz = MIME::Types["application/x-Wingz"].first # => application/x-Wingz
puts xwingz.content_type        # => "application/x-Wingz"
puts xwingz.simplified          # => "application/x-wingz"
```
