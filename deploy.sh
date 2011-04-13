if [ ! -f caboto.war ]
then
    echo Sorry, I need a caboto.war > /dev/stderr ;
    exit 1;
fi

cp caboto.war caboto-rr.war

cd web
jar uf ../caboto-rr.war *

echo All done! > /dev/stderr
