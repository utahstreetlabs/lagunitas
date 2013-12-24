require 'dino/base'
require 'dino/mongoid'
require 'lagunitas/models'

module Lagunitas
  class CreditTriggersApp < Dino::Base
    include Dino::MongoidApp

    get '/credits/:id/trigger' do
      do_get do
        logger.debug("Getting trigger for credit #{params[:id]}")
        CreditTrigger.get_for_credit(params[:id])
      end
    end

    get '/users/:id/triggers' do
      do_get do
        logger.debug("Finding credit triggers for user #{params[:id]}")
        {triggers: CreditTrigger.for_user(params[:id])}
      end
    end

    post '/users/:id/triggers' do
      do_post do |entity|
        type = entity['type'] or raise Dino::BadRequest, 'type is required'
        credit_id = entity['credit_id'] or raise Dino::BadRequest, 'credit_id is required'
        attrs = entity['attrs'] or raise Dino::BadRequest, 'attrs is required'
        begin
          logger.debug("Creating %s credit trigger for user %s and credit %s with attrs %s" %
            [type, params[:user_id], params[:credit_id], attrs.inspect])
          CreditTrigger.create_as_type!(type, attrs.merge(user_id: params[:id], credit_id: credit_id))
        rescue NameError
          logger.warn("WARN: unknown trigger type #{type}")
          raise Dino::BadRequest, "unknown trigger type #{type}"
        end
      end
    end

    delete '/users/:id/triggers' do
      do_delete do
        logger.debug("Deleting credit triggers for user #{params[:id]}")
        CreditTrigger.for_user(params[:id]).destroy_all
      end
    end
  end
end
