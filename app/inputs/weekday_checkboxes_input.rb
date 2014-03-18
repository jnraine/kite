class WeekdayCheckboxesInput < SimpleForm::Inputs::Base
  def input
    raise attribute_name.inspect
    @builder.text_field(attribute_name, input_html_options).html_safe
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