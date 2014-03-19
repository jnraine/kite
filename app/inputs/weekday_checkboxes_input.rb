class WeekdayCheckboxesInput < SimpleForm::Inputs::Base
  def input
    markup = template.content_tag :div, class: "btn-group", data: {toggle: "buttons"} do
      Event.weekday_symbols.each_with_index.map do |weekday_symbol,i|
        text = weekday_symbol[0..2].to_s.capitalize
        labelled_checkbox(text, i)
      end.join.html_safe
    end.html_safe
  end

  def labelled_checkbox(text, value)
    template.content_tag :label, weekday_checkbox(text, value), class: "btn btn-primary"
  end

  def weekday_checkbox(text, value)
    checked = object.send(attribute_name).include?(value)
    [
      template.tag(:input, name: "#{object_name}[#{attribute_name}][]", value: value, type: "checkbox", checked: checked).html_safe, 
      text
    ].join(" ").html_safe
  end
end

# <div class="form-group pretty-checkboxes">
#     <label class="col-md-3 control-label" for="event_repeat">Week Days</label>
#     <div class="col-md-6">
#       <div class="btn-group" data-toggle="buttons">
#         <label class="btn btn-primary">
#           <input type="checkbox"> Mon
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Tue
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Wed
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Thu
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Fri
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Sat
#         </label>

#         <label class="btn btn-primary">
#           <input type="checkbox"> Sun
#         </label>
#       </div>
#     </div>
#   </div>