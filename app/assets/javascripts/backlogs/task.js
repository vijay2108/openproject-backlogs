//-- copyright
// OpenProject Backlogs Plugin
//
// Copyright (C)2013-2014 the OpenProject Foundation (OPF)
// Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
// Copyright (C)2010-2011 friflaj
// Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
// Copyright (C)2009-2010 Mark Maglana
// Copyright (C)2009 Joe Heck, Nate Lowrie
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License version 3.
//
// OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
// The copyright follows:
// Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
// Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

/**************************************
  TASK
***************************************/

RB.Task = (function ($) {
  return RB.Object.create(RB.WorkPackage, {

    initialize: function (el) {
      this.$ = $(el);
      this.el = el;

      // If node is based on #task_template, it doesn't have the story class yet
      this.$.addClass("task");

      // Associate this object with the element for later retrieval
      this.$.data('this', this);
      this.$.on('mouseup', '.editable', this.handleClick);
      this.defaultColor =  $('#rb .task').css('background-color');
    },

    beforeSave: function name() {
      if (this.el && $(this.el).hasClass('dragging')){
        return;
      }
      var c = this.$.find('select.assigned_to_id').children(':selected').attr('color') || this.defaultColor;
      this.$.css('background-color', c);
      this.$.colorcontrast();
    },

    editorDisplayed: function (dialog) {
      dialog.parents('.ui-dialog').css('background-color', this.$.css('background-color'));
      dialog.parents('.ui-dialog').colorcontrast();
    },

    getType: function () {
      return "Task";
    },

    markIfClosed: function () {
      if (this.$.parent('li').first().hasClass('closed')) {
        this.$.addClass('closed');
      } else {
        this.$.removeClass('closed');
      }
    },

    saveDirectives: function () {
      var prev, cellId, data, url;
      window.url = ""        
      window.prev = this.$.prev();
      window.cellId = this.$.parent('li').first().attr('id').split("_");
      window.current = this
      window.data = this.$.find('.editor').serialize() +
                 "&parent_id=" + window.cellId[0] +
                 "&status_id=" + window.cellId[1] +
                 "&prev=" + (window.prev.length === 1 ? window.prev.data('this').getID() : '') +
                 (this.isNew() ? "" : "&id=" + this.$.children('.id').text());
                 
        if (current.isNew()) {
          window.url = RB.urlFor('create_task', {sprint_id: RB.constants.sprint_id});
        }
        else {
          window.url = RB.urlFor('update_task', {id: current.getID(), sprint_id: RB.constants.sprint_id});
          window.data += "&_method=put";
          
        }

        return {
          url: window.url,
          data: window.data
        };
    },

    beforeSaveDragResult: function () {
      if (this.$.parent('li').first().hasClass('closed')) {
        
        // $(".logwork-modal").show()
        // This is only for the purpose of making the Remaining Hours reset
        // instantaneously after dragging to a closed status. The server should
        // still make sure to reset the value.
        this.$.children('.remaining_hours.editor').val('');
        this.$.children('.remaining_hours.editable').text('');
      }
    },

    refreshed : function () {
      var remainingHours = this.$.children('.remaining_hours.editable');

      remainingHours.toggleClass('empty', remainingHours.is(':empty'));
    }
  });
}(jQuery));
