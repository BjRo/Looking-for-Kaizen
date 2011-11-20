module Jekyll
  class CategoryListTag < Liquid::Tag
    def render(context)
      html = ""
      categories = context.registers[:site].categories.keys
     
      html << "<ul id='categories'>\n"

      categories.sort.each do |category|
        posts_in_category = context.registers[:site].categories[category].size
        html << "<li><a href='/blog/categories/#{category}/'>#{category} (#{posts_in_category})</a></li>\n"
      end

      html << "</ul>\n"

      html
    end
  end
end

Liquid::Template.register_tag('category_list', Jekyll::CategoryListTag)
