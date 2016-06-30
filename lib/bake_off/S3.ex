defmodule BakeOff.S3 do
  @s3 Application.fetch_env!(:bake_off, :s3)

  def get_pies do
    { :ok, %{ body: body } } = HTTPoison.get(@s3)
    body
  end
end
