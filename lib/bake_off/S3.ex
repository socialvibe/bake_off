defmodule BakeOff.S3 do
  use ExAws.S3.Client

  @s3 Application.fetch_env!(:bake_off, :s3)

  def config_root do
    Application.get_all_env(:ex_aws)
  end

  def get_pies do
    { :ok, %{ body: body } } = get_object(@s3[:bucket], @s3[:file])
    body
  end
end
